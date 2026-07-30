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
               (commit "77b820f26d5e2ae3e107c830a5ee18c3d26136f2")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "1k8d7sr3s86y4g86k2343cjz3h2hb2b84g4bqqgqyc4gfah2i3xw"))))
 (arguments
     (list #:make-flags #~'("SHLIB_LIBS=-lncurses")
           #:configure-flags #~'("--with-curses")))))
