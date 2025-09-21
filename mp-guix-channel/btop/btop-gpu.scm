(define-module (mp-guix-channel btop btop-gpu)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages bash)
  #:use-module (guix packages btop)
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages linux)) ; for lm-sensors

(define-public btop-gpu
  (package
    (inherit btop)
    (name "btop-gpu")
    (version "1.4.4")
    (arguments
     `(#:configure-flags '()
       #:make-flags (list "GPU_SUPPORT=true")
       #:phases
       (modify-phases %standard-phases
         ;; Remove the default 'check' phase completely
         (assq-delete-all 'check)

         ;; Add a phase to warn if NVIDIA ML library is missing
         (add-before 'install 'check-nvidia-library
           (lambda* (#:key system #:allow-other-keys)
             (let ((nv-lib "/usr/lib/libnvidia-ml.so"))
               (unless (or (file-exists? nv-lib)
                           (file-exists? "/usr/lib64/libnvidia-ml.so"))
                 (display-warning
                  'btop-gpu
                  "Warning: NVIDIA ML library not found. GPU monitoring may not work.")))
             #t)))))))
