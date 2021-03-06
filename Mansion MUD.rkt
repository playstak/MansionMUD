#lang racket
(require srfi/1)
(require srfi/13)
(require srfi/48)
 
 
(define descriptions '((1 "You are in the mantion’s entrance, you see the toilets to the west and kitchen to the east and mantion’s hallway to the north")
                       (2 "You are in the mantion’s toilet, you see the entrance to your west. ")
                       (3 "You are in the mantion’s kitchen, you see the entrance to your east.")
                       (4 "You are in the mantion’s hallway, you see the entrance to your south and living room to your north")
                       (5 "You are in the mantion’s living room, you see the mantion’s hallway to your south and dining room to your east")
                       (6 "You are in the mantion’s dining room, you see the living room to your west and games room to your north")
                       (7 "You are in the games room, you see the dining room to your south and living room to your west")))
(define look '(((directions) look) ((look) look) ((examine room) look)))
(define quit '(((exit game) quit) ((quit game) quit) ((exit) quit) ((quit) quit)))
(define actions `(,@look ,@quit))
 
(define decisiontable `((1 ((north) 4) ((east) 2) ((west) 3) ,@actions)
                        (2 ((west) 1) ,@actions)
                        (3 ((east) 1),@actions)
                        (4 ((north) 5) ((south) 1),@actions)
                        (5 ((south) 4) ((east) 6),@actions)
                        (6 ((west) 5) ((north) 7),@actions)
                        (7 ((south) 6) ((west) 5),@actions)))                        
(define (slist->string l)
  (string-join (map symbol->string l)))
 
(define (get-directions id)
  (let ((record (assq id decisiontable)))
    (let* ((result (filter (lambda (n) (number? (second n))) (cdr record)))
           (n (length result)))
      (cond ((= 0 n)
             (printf "You appear to have entered a room with no exits.\n"))
            ((= 1 n)
             (printf "You can see an exit to the ~a.\n" (slist->string (caar result))))
            (else
             (let* ((losym (map (lambda (x) (car x)) result))
                    (lostr (map (lambda (x) (slist->string x)) losym)))
               (printf "You can see exits to the ~a.\n" (string-join lostr " and "))))))))
(define (assq-ref assqlist id)
  (cdr (assq id assqlist)))
 
(define (assv-ref assqlist id)
  (cdr (assv id assqlist)))
 
(define (get-response id)
  (car (assq-ref descriptions id)))
 
(define (get-keywords id)
  (let ((keys (assq-ref decisiontable id)))
    (map (lambda (key) (car key)) keys)))
(define (list-of-lengths keylist tokens)
  (map
   (lambda (x)
     (let ((set (lset-intersection eq? tokens x)))
      
       (* (/ (length set) (length x)) (length set))))
   keylist))
 
(define (index-of-largest-number list-of-numbers)
  (let ((n (car (sort list-of-numbers >))))
    (if (zero? n)
      #f
      (list-index (lambda (x) (eq? x n)) list-of-numbers))))
 
 
(define (lookup id tokens)
  (let* ((record (assv-ref decisiontable id))
         (keylist (get-keywords id))
         (index (index-of-largest-number (list-of-lengths keylist tokens))))
    (if index
      (cadr (list-ref record index))
      #f)))