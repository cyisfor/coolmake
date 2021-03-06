(define (color name)
	(case name
		((reset) "\x1b[0m")
		((grey) "\x1b[01;30m")
		((red) "\x1b[01;31m")
		((green) "\x1b[01;32m")
		((yellow) "\x1b[01;33m")
		((blue) "\x1b[01;34m")
		((pink) "\x1b[01;35m")
		((cyan) "\x1b[01;36m")
		((white) "\x1b[01;37m")))

(define (status type message)
	(display (string-append
						(color 'white) type
						" "
						(color 'yellow) message
						(color 'reset) "\n")))

