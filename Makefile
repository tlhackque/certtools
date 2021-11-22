# Updates README and creates MD and man (.1) from Perl code's POD
# Version $Id$

all: ssl_status.md ssl_check_chain.md ssl_status.1 ssl_check_chain.1 README.md

README.md : README.md.in getcert ssl_info makereadme
	 ./makereadme getcert ssl_info <README.md.in >$@

%.md : %
	cat $^ | pod2markdown - $@

%.1 : %
	pod2man --section 1 --center "Certificate Tools" --release  "" --date "$(shell date -r $< +'%d-%b-%Y %T')" $< $@
