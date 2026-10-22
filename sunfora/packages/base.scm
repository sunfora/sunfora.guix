(define-module (sunfora packages base)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages base))

(define-public gnu-make-fork
  (package
    (inherit gnu-make)
    (name "make-fork")
    (version "9999")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/sunfora/make")
               (commit "310fcac3a64996d50993b85e7d66d0c09bdcca23")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "0kfnzpwq6zpz836zdmjg1w3smaj824wkxh4nnihji947h2p120x0"))))
    (arguments
      (list
        #:tests? #f
        #:configure-flags #~(list "--disable-nls")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-gnulib-tool-path
              (lambda _
                (substitute* "bootstrap-funclib.sh"
                  (("gnulib_tool=\\$GNULIB_SRCDIR/gnulib-tool")
                   (string-append "gnulib_tool=" #$(file-append gnulib "/bin/gnulib-tool"))))))
            (replace 'bootstrap
              (lambda _
                (invoke "sh" "bootstrap" "--skip-po" "--no-git"))))))
    (native-inputs
     (modify-inputs (package-native-inputs gnu-make)
       (prepend autoconf-2.72 perl gnulib automake texinfo gnu-gettext)))))
