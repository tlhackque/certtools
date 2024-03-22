# SSL\_STATUS

ssl\_status - check the certificate status for hosts and files

# SYNOPSIS

ssl\_status \[options\] \[host\[:port\] ...\] \[file:FILE\] \[@file...\]

    Options:
      --brief              Abbreviate report
      --CAfile=file        Specify bundle file of trusted CA certificates for verification
      --CApath=dir         Specify a hashed directory containing trusted CA certificates for verification.
      --email-to=list      Specify email address(es) to receive reports
      --email-from=addr    Specify email address sending reports
      --format=type        Specify report format
      --initit=file        Read options from file
      --no-init            Inhibits reading the initialization file
      --logo=file|url      Replaces the built-in logo in HTML reports.
      --pretend-its=days   Adjust today by #days - +/-
      --renewbefore=days   Specify days before expiration that certificates should renew.
      --select=sections    Specify the report sections to produce
      --smtp-server=host   Specify host/host:port for SMTP server for sending e-mail
      --smtp-username=user Specify username for authentication with SMTP server
      --smtp-password=pass Specify password for authentication with SMTP server
      --smtp-ssl_mode=key  Specify whether SSL is used for SMTP server connection
      --starttls=proto     Specify that STARTTLS should be used in the connection.
      --stylesheet-file    Specify additional CSS for HTML reports
      --timeout            Specify timeout for connections
      --tlsversion=ver     Specify the version of TLS to connect with
      --type=type          Specify the certificate type desired from the server
      --[no-]warnings      Display or suppress warnings
      --help               brief help message
      --man                full documentation

# OPTIONS

All options can be specified on the command line and in initialization files.

Indirect command files (_@file_) support a subset of the options that affect how _ssl\_status_
connects to systems and what certificates are requested. Thes options are marked _@file_ below.
When used in an indrect command file, they affect only systems mentioned on the same (possibly
continued) line on which they occur.  When used on the command line or initialization file,
they affect systems listed there, and also serve as defaults for systems lised in indirect command
files.

- **--brief** **--no-brief**

    Abbreviate report contents for easier reading (default).  Use **--no-brief** if output will be parsed by a script.

    Currently, **--brief** avoids repeating the hostname in adjacent rows, but this may be changed.
    Note that if a host's certificates expire on different dates, data from other hosts may prevent
    abbreviation.

- **--CAfile**=_file_ **--no-CAfile**

    Specify a file containing one or more trusted CA certificates to verify the host's certificate chain.

    If not specified, the environment variables SSL\_CERT\_FILE and CURL\_CA\_BUNDLE will be tried, and if neither of them is set, OpenSSL's default will be used.

    If **--no-CAfile** is specified, the environment variables are ignored and the system default is used.

- **--CApath**=_dir_ **--CAdir**=_dir_ **--no-CApath** **--no-CAdir** _@file_

    Specify a directory containing hashed links to one or more trusted CA certificates to verify the host's certificate chain.

    If not specified, the environment variable SSL\_CERT\_DIR will be tried.  If it is not set, OpenSSL's default will be used.

    If **--no-CApath** or **--no-CAdir** is specified, the environment variables are ignored and the system default is used.

- **--email-to**=_list_ **--no-email**

    When generating e-mails, send to this (comma separated) list.  May be specified more than once.

- **--email-from**=_address_ **--no-email-from**

    When generating e-mails, use this address as the sender.  This is a privileged operation that may not be supported
    in some environments.

    If not specified, the mailer will generate a default sender address, usually based on the user under which it is running.

- **--format**=_type_

    Generate a report in the specified format: _text_, _MIME_,  or _HTML_.

    _MIME_ includes both text and HTML in MIME format, and is implied by _--email-to_.

    The default is _text_.

- **--initialization-file**=_FILE_

    Read _FILE_ instead of the default initialization file.  _FILE_ must exist.

- **--no-init**

    Inhibits reading the initialization file, which (when present) supplies command arguments that are processed before
    what is typed on the command line.

- **--logo**=_FILE_ **--logo**=_URL_

    By default, HTML output includes a logo and heading.  You can replace the built-in logo by specifying a _png_, _jpg_, or _svg_ file.

    If you don't want the logo and heading, use **--no-logo**.

- **--pretend-its**=_days_

    Adjust the current time by _days_ (use + to advance, - to go back).

    Advancing makes future certificate expirations closer (and overdue times longer), while
    going back can make expired certificates seem unexpired (or less overdue).

    Used for testing expiration warnings/actions.

- **--renewbefore**=_days_ _@file_

    Specifes the number of days before expiration that certificates should renew.

    Default is 30.

- **--select**-_sections_

    Specifies which report section(s) are to be produced.

    Any or all of: _summary_, _expired_, _invalid_, _renewals_

- **--smtp-server**=_=host_

    Specify host/host:port for SMTP server for sending e-mail.

    For unprotected SMTP or STARTTLS, the port is usually 587 or 25.  For direct SSL, 465.

    The port will default to 25 or 465 depending on _--smtp-ssl-mode_.

    If specified more than once, or a comma-separated list is specified, the first available server will be used.

- **--smtp-username**=_user_

    Specify username for authentication with SMTP server.

- **--smtp-password**=_pass_

    Specify password for authentication with SMTP server.

- **--smtp-ssl\_mode**=_key_

    Specify whether SSL/TLS is used for SMTP server connection.

    _key_ is **no** for unprotected SMTP (port 25), **yes** for direct SSL (port 465), or **starttls** (port 25) for
    upgrading an unprotected SMTP connection to TLS with the _starttls_ command.

    If an explict port (e.g. 587) is specified, it will be used.

    The default is to use direct SSL if port 465/smtps is specified, otherwise to attempt STARTTLS if the server supports it.

- **--starttls**=_protocol_ _@file_

    Specifies that STARTTLS is required to make the TLS connection used to verify a host.

    _protocol_ is one of the following:  "smtp", "pop3", "imap", "ftp", "xmpp",
               "xmpp-server", "irc", "postgres", "mysql", "lmtp", "nntp", "sieve", or "ldap"

- **--stylesheet**=_FILE_

    Adds the contents of _FILE_ to the CSS stylesheet embedded with HTML reports.

- **--timeout**=_secs_ _@file_

    Speciries the maximum amount of time that _ssl\_status_ will wait for a TLS connection.

    The default is 120 seconds.

- **--tlsversion**=_version_ _@file_

    Specifies the TLS protocol version to use: 1.1, 1.2, or 1.3.  Note that 1.3 does not support
    RSA certificates.

- **--type**=_type_ _@file_

    Specify that an _ec_ (_ecdsa_) or _rsa_ certificate is desired.  Can specify more than one, in which case
    both will be requested.  If not specified and the server has more than one, the server decides.

- **--\[no-\]warnings**

    Controls whether warning messages are displayed.  The default is **--warnings**.

    Warnings include duplicated files and hosts, which are skipped, and other recoverable conditions.

- **--help**

    Print a brief help message and exits.

- **--man**

    Prints the manual page and exits.

When options require keyword values, the keyword may be abbreviated providing that the abbreviation is unique.

# DESCRIPTION

**ssl\_status** will connect to each host specified and obtain its certificate and any intermediate certificate chain.

Port can be numeric, or a service name (e.g. from /etc/services).

If a port is not specified: if --starttls is specified, the default port for the STARTTLS protocol is used, otherwise 443 (https) is assumed.

If the port is specified as _FILE_, **ssl\_status** will open the specified file and process it as if the certificates were received from a server.
The certificate chain must be in PEM format.  If a filename begins with '.', '/', or '~', or if it contains a '/', the _:FILE_ is inferred, since
no DNS hostname or IP address can have those forms.  

If an argument is of the form _@file_, the file is processed as a list of commands, one per line, in any of the forms described previously.
A line can contain one or more hosts as well as options that apply only to the hosts on that line.

The host-specific options that can be specified in an _@file_ are: _--CAfile_, _--CApath_, _--renewefore_, _--starttls_, _--timout_, _--tlsversion_, and _--type_.
If these are specified on the command line (or equivalently, in an initialization file), they will be used as defaults for
_@file_ hosts.  Options can be negated - e.g. if most hosts are dual-certificate, you might use _--type=ec,rsa_ on the command line, and
exclude a single host in an _@file_ with _--type=rsa_ or _--no-type_.  Options specified in an _@file_ only apply to the
line on which the occur.  However, lines can be continued using a \\ (backslash) as the last character of a line.

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

The default output is a table, ordered by days until expiration, summarizing the status of each
host/file's certificate.  Typically, one would run this weekly in order to make sure
that certificates are being renewed.  The analysis is similar to **ssl\_check\_chain**,
but the result is condensed to one (or with long filenames, two) lines per host.

The **--select** option allows you to select other output.

The default output format is plain text.  HTML can be selected - for example, if you wish to provide the output as a web page.  MIME is used when the output is e-mailed.

You can specify common options in an initialization file, which is processed before the command line.

The initialization file for Unix systems is the first of `./.ssl_status`, `$HOME/.ssl_status`, `/etc/sysconfig/ssl_status`, and `/etc/default/ssl_status`.

For Windows systems: `.\.ssl_status.ini`, `%HOMEDRIVE%%HOMEPATH%\.ssl_status.ini`, `%SSLSTATUS%\ssl_status.ini`.

For VMS systems: `SYS$DISK:[]ssl_status.ini`, `SYS$LOGIN:ssl_status.ini`, `SYS$SYSTEM:ssl_status.ini`.

For any other system: `./.ssl_status`

Comments (beginning with _#_) are ignored, and the contents  are treated as though they were typed on the
command line - with the same quoting rules.

Should you wish to override the options in the initialization file, you can specify the
**--no-init** option on the command line.  **--initialization-file** specifies an alternative file.

# BUGS

Report any bugs, feature requests and/or patches on the issue tracker,
located at `https://github.com/tlhackque/certtools/issues`.  In the
event that the project moves, contact the author directly.

# AUTHOR

Timothe Litt  <litt@acm.org>

# COPYRIGHT and LICENSE

Copyright (c) 2021 Timothe Litt

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

_openssl(1)_

_POD version $Id$_
