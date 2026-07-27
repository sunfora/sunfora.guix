(define-module (sunfora packages readline)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (gnu packages readline))

(define-public readline-fork
  (package
    (inherit readline)
    (name "readline-fork")
    (version "1")
    (source 
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/sunfora/readline")
               (commit "122ef9ab085f")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "17xrlbrfr72q60gjw7j6v227jydax7p0n1rnqf5fxz5bxjfaf87q"))))
 (arguments
     (list #:make-flags #~'("SHLIB_LIBS=-lncurses")
           #:configure-flags #~'("--with-curses")))))
