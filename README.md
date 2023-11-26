# Tools for managing X.509 certificates

This repository contains a number of tools that make managing X.509
certificates easier.  Note that the description in this README may
not reflect the latest version.  Use the -h option for current
information.  Full documentation for `acme_token_check`, `ssl_check_chain` and `ssl_status`
is available by using th `--man` option.  The corresponding `.md` files
[acme_token_check.md](https://github.com/tlhackque/certtools/blob/master/acme_token_check.md),
[ssl_check_chain.md](https://github.com/tlhackque/certtools/blob/master/ssl_check_chain.md), and
[ssl_status.md](https://github.com/tlhackque/certtools/blob/master/ssl_status.md)
in the repository have identical content, and can be consulted without installing the tools.

Recent updates:

 - Added signed distribution kits and Makefile-based install (and uninstall)
 - Added acme_token_check
 - Added ssl_status reporting tool
 - Server certificate selection is more reliable
 - Markdown manual pages are extracted from the POD
 - Improved error reporting
 - Non-Unix OS optimizations
 - Miscellaneous improvements

## Installation

 - See [INSTALL](https://github.com/tlhackque/certtools/blob/master/INSTALL) for installation instructions.
 - It is **not** necessary to clone the repository unless you wish to contribute patches.  The repository contains some files used to build the distribution that are not required to install or use the tools.
   - INSTALL is also in the release tarball, which is located at [https://github.com/tlhackque/certtools](https://github.com/tlhackque/certtools)
   - Look for the `Releases` note on the right side of the page, and click `Latest`
   - Under `Assets`, click a versioned tarball and corresponding signature link
    (Or download using a command line tool such as wget or curl)
    e.g. if the latest release is V2.1.2, you could obtain it with:
    - `wget htps://github.com/tlhackque/certtools/releases/download/V2.1.2/certtools-2.1.2.tar.xz`
    - `wget htps://github.com/tlhackque/certtools/releases/download/V2.1.2/certtools-2.1.2.tar.xz.sig`

## getcert
Get server's TLS certificate

````
Usage: getcert [-aCcdophs] server[:port]

 Get SSL/TLS certificate from server & output as PEM
 Version 384b-0959-e2d9-130d

 Options:
  4             Only use IPv4
  6             Only use IPv6
  a             Report all certificates (including intermediates)
  C: bundle     CA bundle file for verification
  c: type       Type of certificate to request (dual certificate hosts)
  d             Decode certificate (as well as PEM)
  i             Include minimal identifying information with PEM
  o FILE        Output to FILE (default is stdout)
  p: port       Port number for connection (or use server:port)
  s: proto      STARTTLS for proto: one of smtp, pop3, imap, ftp
  t: tlsver     TLS version: ssl, 1, 1.1, 1.2, 1.3

 Establishes an SSL/TLS connection to the specified server and obtains
 the server's X.509 certificate.  The certificate (in PEM) format is
 written to stdout (or FILE), optionally with text decoding.

 The PEM output (with or without -i) is suitable for input to any
 OpenSSL tool and most applications that require certificates.  Those
 that don't ignore text outside the PEM blocks will reject input
 with the information added by -i.

 See ssl_info if more complete (but less cryptic/cluttered than OpenSSL's)
 information about the certificate/connection is desired.

 When working with dual-certificate servers, use -c RSA and -c ECDSA to
 select the desired certificate.

 Requires: OpenSSL

See LICENSE for license.
````

## ssl_info
````
Usage: ssl_info [-C bundle] [-c type] [-s proto] [-t tlsver] [host[: port]]

Display basic certificate information from a server or file
Version 7f6a-7300-667f-7641

 If no host is specified, a file containing a list of hosts to query may
 my specified with -f.  This contains lines HOST [PORT] or HOST[:PORT].
 PORT defaults to 443.
 If port is FILE or "host" starts with ., ~, or / or host includes a /,
 "host" is a PEM filename

 Options:
  4             Only use IPv4
  6             Only use IPv6
  C: bundle     CA bundle file for verification
  c: type       Type of certificate to request (dual certificate hosts)
  d: file       Debug information to file
  f: file       File listing hosts to query
  Q             Quick display of issue, expiration dates, keytype & size (only)
  s: proto      STARTTLS for proto: one of smtp, pop3, imap, ftp
  t: tlsver     TLS version: ssl, 1, 1.1, 1.2, 1.3

 Establishes an SSL/TLS connection to the specified server and obtains
 the server's X.509 certificate and any intermediate certificates offered.

 A summary of the key attributes of each certificate is displayed.

 When working with dual-certificate servers, use -c RSA and -c ECDHA to
 select the desired certificate.

 Requires: OpenSSL

See LICENSE for license.
````

## ssl_check_chain
````
ssl_check_chain [options] [host[:port] ...] [file:FILE] [@file]

 Options:
   --CAfile=file     Specify bundle file of trusted CA certificates for verification
   --CApath=dir      Specify a hashed directory containing trusted CA certificates for verification.
   --starttls=proto  Specify that STARTTLS should be used in the connection.
   --tlsversion=ver  Specify the version TLS to connect with
   --type=type       Specify the certificate type desired from the server
   --help            brief help message
   --man             full documentation

ssl_check_chain will connect to each host specified and obtain its
certificate and any intermediate certificate chain.

Port can be numeric, or a service name (e.g. from /etc/services).

If the port is specified as FILE or the argument looks like a
filename, ssl_check_chain will open the specified file and process
it as if the certificates were received from a server.  The certificate
chain must be in PEM format.

If an argument is of the form @file, the file is processed as a list of
arguments, one per line, in any of the forms described previously.

Each certificate is analyzed in the order received from the server, which
should be from leaf (the server) toward the root (trusted CA). The trust
root is not sent by the server, but is located by OpenSSL via -CAfile or
-CApath.

Any date or verification errors will be reported.

This automates the manual process of determining where and why a
certificate chain is broken.

For details, see ssl_check_chain.md, or use --man.


Requires: Perl, OpenSSL

See LICENSE for license.
````

## ssl_status
````
ssl_status [options] [host[:port] ...] [file:FILE] [@file]

Provides status of all certificates in an inventory, in the
form of a text or HTML report, or a MIME e-mail message.

The default report is a summary, but options to report on
certificates with specific characteristics (e.g. overdue for
renewal, expired, invald) are available.  Reports are always
ordered by time remaining (shortest first).

ssl_status will connect to each host specified and obtain its
certificate and any intermediate certificate chain.

Port can be numeric, or a service name (e.g. from /etc/services).

If the port is specified as FILE or the argument looks like a
filename, ssl_check_chain will open the specified file and process
it as if the certificates were received from a server.  The certificate
chain must be in PEM format.

If an argument is of the form @file, the file is processed as a list of
arguments, one per line, in any of the forms described previously.

Each certificate is analyzed in the order received from the server, which
should be from leaf (the server) toward the root (trusted CA). The trust
root is not sent by the server, but is located by OpenSSL via -CAfile or
-CApath.

Any date or verification errors will be reported.


For details, see ssl_status.md, or use --man.

Requires: Perl, OpenSSL

See LICENSE for license.
````

## acme_token_check

Reports, and optionally removes `_acme-challenge` TXT records from the DNS.

These can be left-over from ACME-based certificate issuance, when the tools
or systems that they run on fail.

Suitable to be run as a `cron` job.

For details, see acme_token_check.md, or use --man.


Requires: Perl

See LICENSE for license.

README version $Id$
