# SSL\_CHECK\_CHAIN

ssl\_check\_chain - check the certificate chain for hosts

# SYNOPSIS

ssl\_check\_chain \[options\] \[host\[:port\] ...\] \[file:FILE\] \[@file...\]

    Options:
      --CAfile=file     Specify bundle file of trusted CA certificates for verification
      --CApath=dir      Specify a hashed directory containing trusted CA certificates for verification.
      --ipversion=n     Restrict connection to IP version 4 or 6
      --starttls=proto  Specify that STARTTLS should be used in the connection.
      --timeout=secs    Specify timeout for TLS connections
      --tlsversion=ver  Specify the version TLS to connect with
      --type=type       Specify the certificate type desired from the server
      --[no-]warnings   Display or suppress warnings
      --help            brief help message
      --man             full documentation

# OPTIONS

The short options take the same argument as the corresponding long options, and are provided
for compatibility with `ssl_info`

- **--CAfile**=_file_ **-C**

    Specify a file containing one or more trusted CA certificates to verify the host's certificate chain.

    If not specified, the environment variables SSL\_CERT\_FILE and CURL\_CA\_BUNDLE will be tried, and if neither of them is set, OpenSSL's default will be used.

- **--CApath**=_file_ **--CAdir**=_file_

    Specify a directory containing hashed links to one or more trusted CA certificates to verify the host's certificate chain.

    If not specified, the environment variable SSL\_CERT\_DIR will be tried.  If it is not set, OpenSSL's default will be used.

- **--ipversion**-_4|6_ **-i**

    Allows connection to only use the specified IP version.

- **--starttls**=_protocol_ **-s**

    Specifies that STARTTLS is required to make the TLS connection.

    _protocol_ is one of the following:  "smtp", "pop3", "imap", "ftp", "xmpp",
               "xmpp-server", "irc", "postgres", "mysql", "lmtp", "nntp", "sieve", or "ldap"

- **--timeout**=_secs_ _@file_

    Speciries the maximum amount of time that _ssl\_check\_chain_ will wait for a TLS connection.

    The default is 120 seconds.

- **--tlsversion**=_version_

    Specify the TLS protocol version to use: 1.1, 1.2, or 1.3.

- **--type**=_type_ **-c**

    Specify that an _ec_ (_ecdsa_) or _rsa_ certificate is desired.

- **--\[no-\]warnings**

    Controls whether warning messages are displayed.  The default is **--warnings**.

    Warnings include duplicated files and hosts, which are skipped, and other recoverable conditions.

- **--help**

    Print a brief help message and exits.

- **--man**

    Prints the manual page and exits.

When options require keyword values, the keyword may be abbreviated providing that the abbreviation is unique.

# DESCRIPTION

**ssl\_check\_chain** will connect to each host specified and obtain its certificate and any intermediate certificate chain.

Port can be numeric, or a service name (e.g. from /etc/services).

If a port is not specified: if --starttls is specified, the default port for the STARTTLS protocol is used, otherwise 443 (https) is assumed.

If the port is specified as _FILE_, **ssl\_check\_chain** will open the specified file and process it as if the certificates were received from a server.
The certificate chain must be in PEM format.  If a filename begins with '.', '/', or '~', or if it contains a '/', the _:FILE_ is inferred, since
no DNS hostname or IP address can have those forms.

If an argument is of the form _@file_, the file is processed as a list of arguments, one per line, in any of the forms described previously.
_@file_s can be nested, but attempting to process the same file more than once is an error.  In an _@file_, blank lines and lines beginning with _#_ are ignored.

_FILE_ and _@file_ names support tilde expansion, but not wildcards.

The validity dates of each certificate returned will be verified, as will its chain.

To request the desired certificate from  dual-certificate servers, you can specify **--type**=_ec_ or **--type**=_rsa_.
This is done by providing a list of acceptable signature algorithms; the connecion will fail if the server doesn't have a matching certificate.

You can also specify **--tlsversion**=_1.1_, **--tlsversion**=_1.2_, or **--tlsversion**=_1.3_ to select the protocol version.

Each certificate is analyzed in the order received from the server or contained in the file, which should be from leaf (the server) toward the root (trusted CA).
The trust root is not sent by the server, but is located by OpenSSL via -CAfile or -CApath.

Any date or verification errors will be reported.

Note that if a trusted (root) certificate has expired, only the root name is available.

This automates the manual process of determining where and why a certificate chain is broken.

# BUGS

Report any bugs, feature requests and/or patches on the issue tracker,
located at `https://github.com/tlhackque/certtools/issues`.  In the
event that the project moves, contact the author directly.

# AUTHOR

Timothe Litt  &lt;litt@acm.org>

# COPYRIGHT and LICENSE

Copyright (c) 2021-2025 Timothe Litt

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

Except as contained in this notice, the name of the author shall not be
used in advertising or otherwise to promote the sale, use or other dealings
in this Software without prior written authorization from the author.

Any modifications to this software must be clearly documented by and
attributed to their author, who is responsible for their effects.

Bug reports, suggestions and patches are welcomed by the original author.

# SEE ALSO

_openssl(1)_ _ssl\_info_

_POD version $Id$_
