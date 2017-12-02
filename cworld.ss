(module cworld mzscheme
  
  ;; A central world module where all world-changing operations are applied.
  ;; TODO: think of better name.
  (require "structures.ss"
           (lib "struct.ss")
           (lib "plt-match.ss")
           (lib "contract.ss"))
  
  
  ;; a cworld contains a world, a list of operations that have been applied,
  ;; and a list of listeners that will get notified whenever we apply a
  ;; new operation.
  (define-struct cworld (world ops listeners))
  
  
  ;; new-cworld: World -> cworld
  (define (new-cworld an-initial-world)
    (make-cworld an-initial-world '() '()))
  
  
  ;; cworld-apply-op: cworld op -> cworld
  ;; Applies an operation on the world.  Anyone who is a listener will get
  ;; notified.
  (define (cworld-apply-op a-cworld an-op)
    (let ([new-cworld (apply-primitive-op a-cworld an-op)])
      (notify-all-listeners! new-cworld)
      new-cworld))
  
  
  ;; cworld-add-listener: cworld listener -> cworld
  ;; Adds a new listener that will get notified whenever we apply operations.
  (define (cworld-add-listener a-cworld a-listener)
    (copy-struct cworld a-cworld
                 [cworld-listeners
                  (cons a-listener (cworld-listeners a-cworld))]))
  
  
  ;; notify-all-listeners!: cworld -> void
  ;; Tell all listeners that the cworld has just processed an operation.
  (define (notify-all-listeners! a-cworld)
    (for-each (lambda (a-listener)
                (a-listener a-cworld))
              (cworld-listeners a-cworld)))
  
  
  ;; op is the base type of all operations we apply against cworlds.
  (define-struct op ())
  ;; op:replace-world: entirely replace the current world with a new one.
  (define-struct (op:replace-world op) (world))
  ;; fill me in: we need more operations.
  
  
  ;; apply-primitive-op: cworld op -> cworld
  (define (apply-primitive-op a-cworld an-op)
    (match an-op
      [(struct op:replace-world (new-world))
       (copy-struct cworld a-cworld
                    [cworld-world new-world]
                    [cworld-ops (cons an-op (cworld-ops a-cworld))])]))
  
  
  
  ;; We define a listener to be a function that can consume a cworld.
  (define listener/c (cworld? . -> . any))
  
  
  (provide/contract
   [struct cworld ([world World?]
                   [ops (listof op?)]
                   [listeners (listof listener/c)])]
   [new-cworld (World? . -> . cworld?)]
   
   [struct op ()]
   [struct (op:replace-world op) ([world World?])]
   
   [cworld-apply-op
    (cworld? op? . -> . cworld?)]
   
   [cworld-add-listener
    (cworld? listener/c . -> . any)]))