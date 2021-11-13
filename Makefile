# Updates README and creates MD from Perl code's POD

all: ssl_status.md ssl_check_chain.md README.md

README.md : README.md.in getcert ssl_info makereadme
	 ./makereadme getcert ssl_info <README.md.in >$@

%.md : %
	cat $^ | pod2markdown - $@

