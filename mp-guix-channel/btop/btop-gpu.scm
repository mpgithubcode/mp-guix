(define-module (my-packages btop-gpu)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (gnu packages)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages linux) ; for sensors
  #:use-module (gnu packages nvidia))

(define-public btop-gpu
  (package
    (name "btop-gpu")
    (version "1.3.2") ; Check latest version
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/aristocratos/btop.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "PLACEHOLDER_HASH")))) ; Replace after initial download
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "PREFIX=" (assoc-ref %outputs "out"))
             "GPU_SUPPORT=true")
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)))) ; No configure script
    (inputs
     (list ncurses
           bash
           lm-sensors
           nvidia-driver)) ; Provides libnvidia-ml
    (native-inputs
     (list cmake pkg-config))
    (home-page "https://github.com/aristocratos/btop")
    (synopsis "Resource monitor with GPU support")
    (description "A monitor of CPU, memory, disks, network and processes. This variant includes GPU support.")
    (license asl2.0)))
