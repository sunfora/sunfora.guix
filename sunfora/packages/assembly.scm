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
  #:use-module (guix gexp)
  #:use-module (guix utils))

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

(define-public blinkenlights-110
  (package (inherit blinkenlights)
    (name "blinkenlights")
    (version "1.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/jart/blink")
                    (commit version)))
              (sha256
               (base32
                "0wlp1hqccbh9jl4h0vyv9kqbff4ccls6kgzz62gnsqnfsmz06273"))
              (file-name (git-file-name name version))))
    (native-inputs
     (modify-inputs (package-native-inputs blinkenlights)
       (prepend python-wrapper)))
    (arguments
     (list #:tests? #f                           ;Tests require network access
           #:phases
           #~(modify-phases %standard-phases
              ;; Make a reproducible binary and -v message somewhat nicer
              (add-before 'configure 'fix-timestamps
                (lambda _
                  (define (enquote str) (format #f "~s" str))
                  (substitute* "Makefile"
                    (("BUILD_TIMESTAMP := .*")
                     (format #f "BUILD_TIMESTAMP := -DBUILD_TIMESTAMP=~s\n"
                             (enquote "guix")))
                    (("BLINK_COMMITS := .*") 
                     (format #f "BLINK_COMMITS := -DBLINK_COMMITS=~s\n"
                             (enquote "?")))
                    (("BLINK_GITSHA := .*") 
                     (format #f "BLINK_GITSHA := -DBLINK_GITSHA=~s\n"
                             (enquote #$version))))))
               ;; Call ./configure without --enable-fast-install argument, which
               ;; causes the script to fail with an "unsupported option" error.
               (replace 'configure
                 (lambda* (#:key inputs outputs #:allow-other-keys)
                   (invoke "sh" "configure"
                           (string-append "CC=" #$(cc-for-target))
                           (string-append "--prefix="
                                          (assoc-ref outputs "out"))))))))))
