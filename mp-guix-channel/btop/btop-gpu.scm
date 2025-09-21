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
  #:use-module (gnu packages linux)) ; for lm-sensors

(define-public btop-gpu
  (package
    (name "btop-gpu")
    (version "1.3.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/aristocratos/btop.git")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "REPLACE-WITH-GUIX-DOWNLOAD-HASH"))))
    (build-system gnu-build-system)
    (arguments
     `(#:make-flags
       (list (string-append "PREFIX=" (assoc-ref %outputs "out")))
       #:phases
       (modify-phases %standard-phases
         (delete 'configure))))
    (inputs
     (list ncurses
           bash
           lm-sensors)) ; enables hwmon/GPU sensor access
    (native-inputs
     (list cmake pkg-config))
    (home-page "https://github.com/aristocratos/btop")
    (synopsis "Resource monitor with optional GPU support")
    (description
     "A resource monitor for CPU, memory, disks, network and processes.
      This variant is prepared for GPU monitoring if the appropriate runtime
      libraries (such as libnvidia-ml for NVIDIA or rocm-smi for AMD) are available.")
    (license asl2.0)))
