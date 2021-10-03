# Tools for managing X.509 certificates

This repository contains a number of tools that make managing X.509
certificates easier.  Note that the description in this README may
not reflect the latest version.  Use the -h option for current
information.

## getcert
Get server's TLS certificate

````
Usage: getcert [-acdophs] server

 Get SSL/TLS certificate from server & output as PEM
 V1.0.0

 Options:
  a             Report all certificates (including intermediates)
  c: cipher     Cipher list (man ciphers/openssl ciphers)
  d             Decode certificate (as well as PEM)
  o FILE        Output to FILE
  p: port       Port number for connection
  s: proto      STARTTLS for proto: one of smtp, pop3, imap, ftp

 Establishes an SSL/TLS connection to the specified server and obtains
 the server's X.509 certificate.  The certificate (in PEM) format is
 written to stdout (or FILE), optionally with text decoding.

 When working with dual-certificate servers, use -c RSA and -c ECDSA to
 select the desired certificate.  An arbitrary list can be specified.

 Requires: OpenSSL

See LICENSE for license.
````

## ssl_info
````
Usage: ssl_info [-C bundle] [-c cipher] [-s proto] [-t tlsver] [host [port]]

Display basic certificate information from a server or file
V1.0.1

 If no host is specified,  is read.  This contains lines HOST [PORT].
 PORT defaults to 443.
 If port is FILE, "host" is a PEM filename

 Options:
  C: bundle     CA bundle file for verification
  c: cipher     Cipher list (man ciphers/openssl ciphers)
  s: proto      STARTTLS for proto: one of smtp, pop3, imap, ftp
  t: tlsver     TLS version: ssl, 1, 1.1, 1.2, 1.3

 Establishes an SSL/TLS connection to the specified server and obtains
 the server's X.509 certificate and any intermediate certificates offered.

 A summary of the key attributes of each certificate is displayed.

 When working with dual-certificate servers, use -c RSA and -c ECDHA to
 select the desired certificate.  An arbitrary list can be specified.

 Most errors are silently ignored; I'm too lazy to sort out
 verification errors, inaccessible host, etc.

 Requires: OpenSSL
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


Requires: Perl, OpenSSL
````
