;; NVIDIA modprobe
(define-public nvidia-modprobe
  (package
    (name "nvidia-modprobe")
    (version "550.54.14")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/NVIDIA/nvidia-modprobe")
                    (commit version)))
              (file-name (git-file-name name version))
              (sha256 (base32 "1a7q03pnwk3wa0p57whwv2mvz60bv77vvvaljqzwnscpyf94q548"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
          (delete 'configure)
          (add-before 'build 'set-correct-cflags
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (setenv "CFLAGS" "-fPIC")))
          (add-after 'build 'build-static-link-libraries
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (invoke "ar" "rcs" "_out/Linux_x86_64/libnvidia-modprobe-utils.a"
                      "_out/Linux_x86_64/nvidia-modprobe-utils.o"
                      "_out/Linux_x86_64/pci-sysfs.o")
              (copy-recursively "_out/Linux_x86_64/"
                                (string-append (assoc-ref %outputs "out") "/lib"))))
          (delete 'check)
          (add-after 'patch-source-shebangs 'replace-prefix
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (setenv "CC" "gcc")
              (setenv "PREFIX" (assoc-ref %outputs "out"))
              (copy-recursively "modprobe-utils/"
                                (string-append (assoc-ref %outputs "out") "/include"))
              #t)))
      #:tests? #f))
    (native-inputs (list gcc-toolchain m4))
    (synopsis "Load the NVIDIA kernel module and create NVIDIA character device files")
    (description "Load the NVIDIA kernel module and create NVIDIA character device files")
    (home-page "https://github.com/NVIDIA/nvidia-modprobe")
    (license gpl2)))
