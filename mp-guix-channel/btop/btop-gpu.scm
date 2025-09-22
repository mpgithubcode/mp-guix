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
  #:use-module (gnu packages rocm))  ;; Ensure ROCm support is available

(define-public btop-gpu
  (package
    (inherit btop)
    (name "btop-gpu")
    (version "1.4.4")
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; Replace build phase to enable GPU support
         (replace 'build
           (lambda* (#:key outputs #:allow-other-keys)
             (invoke "make" (list "GPU_SUPPORT=true"))))))))
