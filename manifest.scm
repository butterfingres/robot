(use-modules (gnu packages base)
             (gnu packages embedded)
             (guix build-system gnu)
             (guix gexp)
             (guix git-download)
             (guix packages)
             ((guix licenses) #:prefix license:))

(define arm-none-eabi-toolchain
  (make-arm-none-eabi-toolchain-12.3.rel1))

(define pros-2
  (package
   (name "pros")
   (version "2.12.2")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/purduesigbots/pros.git")
           (commit version)))
     (file-name (git-file-name name version))
     (sha256
      (base32
       "061jqvhv3n0lp52hs06mm4qgr2wk85nlbnvl4hxzwslpq2zwkscr"))))
   (build-system gnu-build-system)
   (arguments `(#:make-flags '("OUTBIN=bin/libpros.a")
                #:tests? #f
                #:phases ,#~(modify-phases %standard-phases
                              (replace 'configure
                                       (lambda* (#:key outputs #:allow-other-keys)
                                         (substitute* "common.mk"
                                           (("\\/bin\\/echo")
                                            #$(file-append coreutils "/bin/echo")))))
                              (replace 'install
                                       (lambda* (#:key outputs #:allow-other-keys)
                                         (let* ((root (string-append #$output "/arm-none-eabi"))
                                                (lib-dir (string-append root "/lib")))
                                           (mkdir-p lib-dir)
                                           (install-file "bin/libpros.a" lib-dir)
                                           (copy-recursively "include" root)))))))

   (native-inputs (list arm-none-eabi-toolchain))
   (home-page "https://pros.cs.perdue.edu")
   (synopsis "Kernel for the Vex Cortex 2.0.")
   (description
    "PROS is a lightweight and fast alternative open source operating
system for the VEX Cortex Microcontroller. It features multitasking,
low-level control, and Wiring compatible functions to harness the full
power of the Cortex. PROS is built with developers in mind and with a
focus on providing an environment for industry-applicable experience.")
   (license license:mpl2.0)))

(concatenate-manifests
 (list (packages->manifest (list arm-none-eabi-toolchain
                                 pros-2))
       (specifications->manifest '("make"))))
