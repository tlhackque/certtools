# getcert
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
