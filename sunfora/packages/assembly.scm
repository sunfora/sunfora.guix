(define-module (sunfora packages assembly)
  #:use-module (guix packages)  
  #:use-module (guix download)
  #:use-module (gnu packages assembly)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages ghostscript)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages fonts)
  #:use-module (guix gexp))

(define-public nasm-latest-stable
  (package (inherit nasm)
    (name "nasm")
    (version "3.02")
    (source (origin
              (method url-fetch)
              (uri (string-append "http://www.nasm.us/pub/nasm/releasebuilds/"
                                  version "/nasm-" version ".tar.xz"))
              (sha256
               (base32
                "039gf7xjrkrw4z13b38lypcm801b1m85var4fj8zxb5lafx6wcw7"))

              ;; fix reproducibility issues by reusing the work of team Debian
              (patches 
                (list 
                  ;; removes absurd `compiled on <DATE>` message
                  ;; without it on guix nasm -v shows `compiled on Jan  1 1970`
                  (origin 
                    (method url-fetch)
                    (uri "https://sources.debian.org/data/main/n/nasm/3.01-1/debian/patches/0003-debian-debian-patches-04-reproducible-build.patch.patch")
                    (sha256
                      (base32 
                        "1knj7ggnwcmqcy1p9cb134zj4v4a60452mslkf1cmdfgm3nafix4")))
                  ;; fixes unsorted key hazard from perl during pdf documentation generation
                  (origin 
                    (method url-fetch)
                    (uri "https://sources.debian.org/data/main/n/nasm/3.01-1/debian/patches/0007-doc-sort-keys-for-reproducibility.patch")
                    (sha256
                      (base32 
                        "0608slsll2yj39hy8y8if54zg0vzhnrv052zizzwmsvj8b25d8v2")))))))

    (native-inputs (list perl ;for doc and test target
                         texinfo
                         fontconfig
                         ;; as recommended by the nasm doc/README
                         perl-font-ttf
                         perl-sort-versions
                         asciidoc
                         xmlto
                         font-google-roboto
                         font-google-roboto-mono
                         ghostscript))
    (arguments
      (list
        #:test-target "test"
        #:phases
        #~(modify-phases %standard-phases
           (add-after 'install 'install-doc
             (lambda* _
               (let* ((roboto       #+(this-package-native-input "font-google-roboto"))
                      (roboto-mono  #+(this-package-native-input "font-google-roboto-mono"))
                      (fonts        (list roboto roboto-mono))
                      (fonts-share  (map (lambda (x) (string-append x "/share")) fonts)))
                ;; fontconfig needs a cache dir to operate properly
                ;; and would search fonts according to XDG_DATA_DIRS env var
                (setenv "XDG_CACHE_HOME" "/tmp/cache")
                (setenv "XDG_DATA_DIRS"  (string-join fonts-share ":"))
                ;; finally make ghostscript pdfs generation reproducible
                ;; https://issues.guix.gnu.org/issue/49640
                (setenv "GS_GENERATE_UUIDS" "0")
                ;; finally build the docs
                (invoke "make" "doc")
                (invoke "make" "install_doc")))))))))
