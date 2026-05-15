(define-module (project-management ini-merge)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system copy)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (guix build utils))

(define-public ini-merge
  (package
    (name "ini-merge")
    (version "1.0.0")

    (source
     (origin
       (method git-fetch)
       (uri
        (git-reference
         (url "https://github.com/sunfora/ini-merge")
         (commit "main")))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "0pi0vzsm49v0ng4vm53ds014dq9b0fibyphvb1ksz12wmw27x329"))))

    (build-system copy-build-system)

    (arguments
     `(#:install-plan
       '(("project-management/ini-merge.scm"
          "share/guile/site/3.0/project-management/")
         ("main.scm"
          "share/ini-merge/"))

       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'make-bin
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (let* ((out   (assoc-ref outputs "out"))
                    (bin   (string-append out "/bin"))
                    (prog  (string-append bin "/ini-merge"))
                    (guile (search-input-file inputs "/bin/guile"))
                    (sh    (search-input-file inputs "/bin/sh")))

               (mkdir-p bin)

               (call-with-output-file prog
                 (lambda (p)
                   (format p
                           "#!~a~%
export GUILE_LOAD_PATH=\"~a/share/guile/site/3.0${GUILE_LOAD_PATH:+:}$GUILE_LOAD_PATH\"~%
export GUILE_LOAD_COMPILED_PATH=\"~a/lib/guile/3.0/site-ccache${GUILE_LOAD_COMPILED_PATH:+:}$GUILE_LOAD_COMPILED_PATH\"~%
exec ~a -s ~a/share/ini-merge/main.scm \"$@\"~%"
                           sh
                           out
                           out
                           guile
                           out)))

               (chmod prog #o555)
               #t))))))

    (propagated-inputs
     `(("bash" ,bash-minimal)
       ("guile" ,guile-3.0)
       ("guile-ini" ,guile-ini)))

    (synopsis "INI merge utility")
    (description "Merge INI files preserving order.")
    (home-page "https://github.com/sunfora/ini-merge")
    (license license:gpl3+)))
