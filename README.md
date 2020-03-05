# Tools for managing X.509 certificates

This repository contains a number of tools that make managing X.509
certificates easier.

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
