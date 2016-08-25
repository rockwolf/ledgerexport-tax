;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author: Andy Nagels
; Date: 2016-08-23
;
; ledgerexport-tax.lisp:
; Script that prepares data for the quarterly tax reports.
; It uses ledger data as a backend and also depends on vim for transforming
; the final report outputs from txt to pdf.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require "asdf")


; Global variables.
(defconstant +g-months+ (list 'january 'february 'march 'april 'may 'june 'july 'august 'september 'oktober 'november 'december))
(defconstant +g-termprefix+ ">>> ")
(defconstant +g-possible-arguments+ (list 'Q1 'Q2 'Q3 'Q4))

; usage:
; Print usage info.
(defun usage ()
  (format t "Usage: ledgerexport-tax.cl [Q1|Q2|Q3|Q4|month|-h]~%~%")
  (format t "Options:~%")
  (format t "~{~4tQ~a: exports the data for Q~a~%~}" (list 1 1 2 2 3 3 4 4))
  (format t "~4tmonth: exports the given month~%")
  (format t "~8t(valid months are: january, february, march, april, may,~%")
  (format t "~8t june, july, august, september, oktober, november, december)~%")
  (format t "~4t-h: shows this usage info message~%"))

; current-date-string:
; Returns the current date as a string in YYYYMMDD format.
(defun current-date-string ()
  (multiple-value-bind (sec min hr day mon yr dow dst-p tz)
    (get-decoded-time)
    (declare (ignore sec min hr dow dst-p tz))
    (format nil "~4,'0d~2,'0d~2,'0d" yr mon day)))

; get-export-name:
; Determine name to use for the output.
(defun assemble-export-name (a-argument)
  ; TODO: get current date etc.
  (concatenate 'string "reg_" (current-date-string) "_V001_btw_" (string-upcase a-argument) ".txt") 
  ; "reg_20160822_V001_btw_Q2.txt"
)

; export-to-txt:
; Export accounting register data to txt,
; for the given period.
(defun export-to-txt (a-argument)
  (format t "~aExporting data to ~a...~%" +g-termprefix+ (assemble-export-name a-argument))
  ; TODO: The below is a windows test for application calling. Remove it.
  (uiop:run-program `("C:\\Program Files (x86)\\Gow\\bin\\ls.exe" "-lh") :output t :error-output t)
  ; TODO: if a-argument in Q1-4 then call ledger with the appropriate dates.
  ; if a-argument in months then call ledger with -p? But what about the year?
  ; TODO: the below with (intern a-argument), only for the months.
  ; Also check if -p "january this year" is a valid PERIOD_EXPRESSION in ledger.
  (uiop:run-program `("ledger -f ledger.dat" "-p \"" (intern a-argument) " this year\"" "-lh") :output t :error-output t)
  ;ledger -f ledger.dat -b "2016/06/01" -e "2016/07/01" reg | sort -n > reg_(date +%Y%m%d)_V001_btw_Q1
)

; process-arguments:
; Print usage info
; or start export for a valid given period.
(defun process-arguments (a-argument)
  (cond
    ((equal a-argument "-h") (usage))
    ; Note: (intern ...) = string->symbol
    ((or
      (member (intern a-argument) +g-possible-arguments+)
      (member (intern a-argument) +g-months+))
        (export-to-txt a-argument))
    (T (usage))))

; main
; Main code processing.
(defun main ()
  ; TODO: month->number?
  ; info: number->month = (nth 1 +g-months+) = February
  ; TODO: read cli params?
  (format t "[DEBUG] Argument = ~a~%" (nth 1 sb-ext:*posix-argv*))
  (cond
    ((eq (length sb-ext:*posix-argv*) 2) (process-arguments (string-upcase (nth 1 sb-ext:*posix-argv*))))
    (T (usage))))

; Main entry point, to start the code.
(main)
