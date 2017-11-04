/* compile, but capture stderr. if "fatal error: X.h: No such file or directory"
	 then add make rule ourtarget: X.h, then $(MAKE) ourtarget and return.
*/
