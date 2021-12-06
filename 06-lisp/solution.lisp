;; Run with GNU Common Lisp compiler.

(defun get-input (filename)
  (with-open-file (stream filename)
  	(loop for c across (read-line stream nil)
	      when (not (eq c #\,))
	      collect (digit-char-p c))))

;; Memoize get-count calls.
(defparameter *memory* (make-hash-table))

;; Timers are at most 8, so we could easily construct integer keys.
(defun get-key (day timer)
  (+ (* day 10) timer))

(defun get-value (day timer)
  (gethash (get-key day timer) *memory*))

(defun set-value (day timer value)
  (setf (gethash (get-key day timer) *memory*) value))

(defun get-count (day timer)
  (setq cnt (get-value day timer))
  (if cnt 
    cnt
    (progn (cond ((eq day 0) (setq res 1))
                 ((eq timer 0) (setq res (+ (get-count (- day 1) 6)(get-count (- day 1) 8))))
	         (t (setq res (get-count (- day 1) (- timer 1)))))
     (set-value day timer res)
     res)))

(defun solve (filename days)
  (setq inp (get-input filename))
  (setq result 0)
  (loop for timer in inp
        do (setq result (+ result (get-count days timer))))
  result)

(defun solution1 (filename)
  (solve filename 80))

(defun solution2 (filename)
  (solve filename 256))

(format T "Day 6:~%")
(format T "Solution 1: ~d~%" (solution1 (car *args*)))
(format T "Solution 2: ~d~%" (solution2 (car *args*)))
