(define-module (sunfora packages javascript)
  #:use-module (guix packages)
  #:use-module (guix build-system copy)
  #:use-module (gnu packages javascript)
)

(define-public quickjs-ng-extras
  (package 
    (name "quickjs-ng-extras")
    (version (package-version quickjs-ng))
    (source  (package-source  quickjs-ng))

    (build-system copy-build-system)
    
    (arguments
     `(#:install-plan
       '(
         ("quickjs-libc.h"   "include/quickjs-libc.h")
         ("quickjs-opcode.h" "include/quickjs-opcode.h")
        )
      )
     )


    (propagated-inputs
     `(("quickjs-ng" ,quickjs-ng)))
       
    (synopsis "More headers for quickjs-ng.")
    (description "In order to properly compile everything 
                  in quickjs you need quite more than just
                  having quickjs.h or something alike.")
    (home-page (package-home-page quickjs-ng))
    (license   (package-license quickjs-ng))))
