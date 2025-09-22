(define-module (mp-guix-channel btop btop-gpu)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages admin)
  #:use-module (guix build utils)  ;; provides nproc
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages nvidia)  ;; Ensure NVIDIA utilities are available
  #:use-module (gnu packages rocm))  ;; Ensure ROCm support is available

;; Assuming the btop package is defined elsewhere, we inherit it.
;; If it isn't defined, we would need to create the btop package.
(define-public btop-gpu
  (package
    (inherit btop)  ;; Inherit from the existing btop package (ensure btop is defined)
    (name "btop-gpu")
    (version "1.4.4")
    (source (origin
             (method git-fetch)
             (uri (git-reference
                   (url "https://github.com/aristocratos/btop")
                   (commit version)))
             (sha256
              (base32
               "0w35v8kfyxs0q9d64d67nklpkrgklh38jsfpmmgnfzb0wj7lhxf7"))))
    (build-system gnu-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; Remove configure phase (as it's not needed for this package)
         (delete 'configure)

         ;; Pre-install NVIDIA library check
         (add-before 'install 'check-nvidia-library
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((nv-lib "/usr/lib/libnvidia-ml.so"))
               (unless (or (file-exists? nv-lib)
                           (file-exists? "/usr/lib64/libnvidia-ml.so"))
                 (display-warning
                  'btop-gpu
                  "Warning: NVIDIA ML library not found. GPU monitoring may not work.")))
             #t))

         ;; Replace build phase with explicit GPU build
         (replace 'build
           (lambda* (#:key outputs #:allow-other-keys)
             (setenv "CC" "gcc")  ;; Explicitly set CC to gcc
             (invoke "make"
                     (list "GPU_SUPPORT=true")))))))


    (native-inputs
     `(("pkg-config" ,pkg-config)
       ("nvidia-utils" ,nvidia-utils)
       ("rocm-smi-lib" ,rocm-smi-lib)))

    (inputs
     `(("ncurses" ,ncurses)
       ("libfmt" ,libfmt)))

    (home-page "https://github.com/aristocratos/btop")
    (synopsis "Resource monitor with GPU support")
    (description
     "btop is a resource monitor that shows usage and stats for processor, memory, disks, network and processes. This variant includes GPU support.")
    (license license:mit)))

