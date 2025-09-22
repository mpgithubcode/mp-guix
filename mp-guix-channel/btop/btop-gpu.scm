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
  #:use-module (gnu packages rocm)  ;; Ensure ROCm support is available
  #:use-module (gnu packages commencement)  ;; for gcc-toolchain
  #:use-module (guix utils))  ;; for package-input-rewriting helpers

(define-public btop-gpu
  (package
    (inherit btop)
    (name "btop-gpu")
    (version "1.4.4")
    (native-inputs
     (append
      (list gcc-toolchain)
      (alist-delete "_"
                    (package-native-inputs btop))))
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         ;; Remove configure phase (btop doesn’t have one)
         (delete 'configure)
         ;; Replace build phase with GPU flag and proper compilers
         (replace 'build
           (lambda* (#:key outputs #:allow-other-keys)
             (invoke "make"
                     "GPU_SUPPORT=true"
                     "CC=gcc"
                     "CXX=g++"))))))))
