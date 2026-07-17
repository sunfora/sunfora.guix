(define-module (sunfora packages assembly)
  #:use-module (guix packages)  
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages base)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages python)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages docbook)
  #:use-module (guix gexp))

(define-public nasm-next
  (package (inherit nasm)
    (name "nasm-next")
    (version "3.02")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/netwide-assembler/nasm")
                     (commit (string-append "nasm-" version))))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "120awanzgs0xzi4mmrgs6wdn50jhj9bb9vxjjbbgpxn40g4ybwx0"))))
    (native-inputs (list ;; required for `test` target
                         perl
                         python-wrapper
                         ;; required for bootstrap from git
                         autoconf-2.72
                         automake
                         which
                         ;; required for target `manpages`
                         asciidoc
                         xmlto
                         docbook-xsl
                         ;; required for target `doc`
                         perl-font-ttf
                         perl-sort-versions
                         fontconfig
                         font-google-roboto
                         font-google-roboto-mono
                         ghostscript))
    (arguments
      (list
        #:test-target "travis"
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'set-env-for-reproducibile-build
              (lambda _
               ;; make ghostscript pdfs generation reproducible
               ;; https://issues.guix.gnu.org/issue/49640
               (setenv "GS_GENERATE_UUIDS" "0")
               (setenv "PERL_HASH_SEED"    "0")))
            (replace 'bootstrap
              (lambda _
                (invoke "sh" "autogen.sh")))
            (add-after 'build 'build-manpages
              (lambda _
                 (invoke "make" "manpages")))
            (add-after 'build 'build-doc
              (lambda _
                (let* ((fonts
                        (list
                          #+(this-package-native-input "font-google-roboto")
                          #+(this-package-native-input "font-google-roboto-mono")))
                       (font-share-paths
                        (map (lambda (x) (string-append x "/share")) fonts)))
                 ;; fontconfig needs a cache dir to operate properly
                 ;; and would search fonts according to XDG_DATA_DIRS env var
                 (setenv "XDG_CACHE_HOME" "/tmp/cache")
                 (setenv "XDG_DATA_DIRS"  (string-join font-share-paths ":"))
                 ;; finally build the docs
                 (invoke "make" "doc"))))
            (add-before 'check 'unset-perl-hash-seed
               (lambda _
                 (unsetenv "PERL_HASH_SEED")))
            (add-after 'install 'install-doc
               (lambda _
                 (invoke "make" "install_doc"))))))))

