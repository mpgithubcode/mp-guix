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
  #:use-module (gnu packages admin)
  #:use-module (guix build utils)  ;; for nproc
  #:use-module (srfi srfi-1)
  #:use-module (gnu packages linux))

(define-public btop-gpu
  (package
    (inherit btop)
    (name "btop-gpu")
    (version "1.4.4")
    (arguments
     `(#:make-flags (list "GPU_SUPPORT=true")
       #:phases
       (modify-phases %standard-phases
         (delete 'check)
         ;; Pre-install NVIDIA check
         (add-before 'install 'check-nvidia-library
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((nv-lib "/usr/lib/libnvidia-ml.so"))
               (unless (or (file-exists? nv-lib)
                           (file-exists? "/usr/lib64/libnvidia-ml.so"))
                 (display-warning
                  'btop-gpu
                  "Warning: NVIDIA ML library not found. GPU monitoring may not work.")))
             #t))
         ;; Build phase
         (add-before 'install 'build-btop-gpu
           (lambda* (#:key outputs #:allow-other-keys)
             (invoke "make" (list "-j" (number->string (nproc)) "GPU_SUPPORT=true"))
             #t))))))
