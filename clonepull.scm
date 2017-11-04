(define (flavor var)
	(string->symbol
	 (gmk-expand (string-append "$(flavor " (symbol->string var) ")"))))

(define (from-make var)
	(if (eq? (flavor var) 'undefined)
			nil
			(gmk-expand (string-append "$(" (symbol->string var) " )"))))

(define (defined val) (not (eq? val nil)))

(define dest (from-make 'dest))

(when (eq? dest nil)
	(error "need to define a destination directory"))

(define local (from-make 'local))
(define remote (from-make 'remote))

(when (not (or (defined local) (defined remote)))
	(error "Need to define local or remote"))

(define (dir? path)
	(eq? 'directory (stat:type (stat path))))

(define clone-from-local (and (defined local) (dir? local)))

(define check (from-make 'check))

(define (check-system cmd)
	(let ((result (system cmd)))
		(when (not (= result 0))
			(error (string-append "command failed: " cmd)))))

(define (clonepull)
	(if (dir? dest)
			;; maybe pull
			(when (defined check)
				(chdir dest)
				(check-system "git pull local master")
				(when (not clone-from-local)
					(check-system "git pull origin master")))
			;; need clone
			(if clone-from-local
					(begin
						(check-system (string-join " " "git clone  --recursive" local dest))
						(chdir dest)
						(when remote
							(system "git remote set-url origin" remote))
						(when local
							(system "git remote set-url local" local))
						(chdir ".."))
					(check-system (string-join " " "git clone  --recursive" remote dest)))))
