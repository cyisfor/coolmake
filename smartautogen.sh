cd $1 || exit 3

if [[ -e autogen.sh ]]; then
		NOCONFIGURE=1
		sh ./autogen.sh --help
else
		exec autoreconf -i
fi
