# ACME\_TOKEN\_CHECK

acme\_token\_check - check DNS domain(s) for stray ACME tokens

# SYNOPSIS

acme\_token\_check \[options\] \[domain ...\]

    Options
      --debug       --named-address  --nameservers  --ns-port --recurse
      --option      --init-file      --remove       --source-address
      --tsig-key    --source-port    --verbose      --view    --display
      --cnames-for  --target-zone    --hash         --install
      --help        --man            --version

If no domain is specified, domains can be obtained from `named` if its statistics
channel is available.

# OPTIONS

- **--cnames-for**=_source_

    List of source \[sub-\]domains for CNAME redirection from each domain.

    E.g. `www,host1,host2` or `*` for wildcard.

    Do not include the parent domain name.

    Use '.' to specify the domain itself.  "\*" is an alias for '.' for
    the purposes of ACME wildcard validation.

- **-d** **--\[no\]debug**

    Display debugging output from DNS queries.

- **-D** **--display**=_txt|cnames|both_

    Display all records found of the specified type(s).  Default is TXT.

    Records of the type(s) being removed are always displayed.

- **--hash**\[=_n_\]

    When generating CNAMEs, include a hash of the source domain in the target
    instead of the source domain itself.  This ensures that all the target names
    are a fixed length, but prevents backtracking from a stranded token to the
    client.  _n_ is the length of the hash (in characters) used in the target
    domain name.  A random factor makes each re-generation unique.

    If not specified, hashing is not used.  If _n_ is omitted, 32 is used.
    _n_ must be less than 64, since the hash is a single DNS label.

- **--install**

    When generating CNAMEs, install them with DNS UPDATE.

- **--named-address**=_address\[:port\]_

    Use a `named` statistics channel to obtain a list of zones to process.
    The address can be a literal address or a hostname.  It may be prefixed
    by `https://` if `named` is behind an https proxy.  The default
    protocol is `http://`, port 80.

    Not accessed if any domain name(s) specified on the command line.

- **--nameservers**-_addr,..._

    Name(s) and/or Address(es) of nameservers to use.  If not specified, the
    default resolvers will be used to obtain the zone's NS records.

    The **tsig-key** and/or **source-address** will be used for this query.

    Updates (to remove records) are always sent to the **SOA**'s _mname_.

- **--ns-port**=_port_

    Destination port of nameservers.  Use if nameservers listen on a non-standard port
    (e.g. test nameservers).

    Default is 53.

- **--\[no\]recurse**

    Scan delegations (subzones) of the specified domains.  Default is **--recurse**,

    Not applicable to CNAME generation.

- **-r** **--\[no\]remove**=_none|txt|cnames|both_

    Remove all records found of the specified type(s).  Default type for **--remove** is _txt_.

    Requires the nameserver hosting a zone to support and permit dynamic updates (RFC2136).
    The nameserver may require updates to be from a specified address (or subnet) and/or port,
    or to be TSIG-signed.

    Removing _cnames_ is not common; they are usually a static delegation.

    Default if not specified is **--noremove**.

- **--reverse-zones**

    Process zones in the `in-addr.arpa` and `ip6.arpa` domains.

    Default is **--no-reverse-zones**.

- **-s** **--source-address**=_address_

    Send queries from _address_.  Default is any local address.

- **--source-port**=_port_

    Send queries from _port_.  Default is any local port.

- **--target-zone**=_updatable.domain_

    Specifies the target of generated CNAME records.  This must be a domain that
    can be updated during ACME verification.

- **-k** **--tsig-key**=_file_

    Specify a file containing TSIG key to use for the domain(s).

    The default is not to sign queries or updates.

- **--\[no\]unique-names**

    When generating CNAMEs, with **--unique** each CNAME on a host covered by the
    certificate targets a unique name on the target validation server.  The target
    name either includes the full domain name of the client certificate, or a
    hash of that name and a random factor.  See **--hash** for information about the
    latter.

- **-V** **--view**=_name_

    Specify view to be used when obtaining zone list with **--named-address**.

    View selection used for queries (and updates) may be influenced by **--tsig-key**
    and/or **--source-address**, depending on the nameserver.

    The default is to use the **\_default** view.

- **-v** **--\[no\]verbose**

    Report all findings/actions.

    Default is to report totals if any records are found, and to report errors.

- **--help**

    Print a brief help message and exit.

- **--man**

    Print the manual page and exit.

# DESCRIPTION

**acme\_token\_check** scans the specified domain(s) and any subdomains for **TXT**
and/or **CNAME** records of the form:

    _acme-challenge.*

With **--verbose** tnose found will be reported.

With **--remove**, those found will be removed from the DNS.

With **--target-zone**, creates CNAME records for verification redirection.

These records are created when the ACME protocol is used to obtain TLS certificates,
validating domain ownership with its _DNS-01_ option.

The **TXT** records should be removed, but system or software failures can leave them in the DNS.

**acme\_token\_check** performs a zone transfer (AXFR) in order to locate the
**TXT** and/or **CNAME** records.  If requested, it uses DNS UPDATE to remove **TXT**
and to install **CNAME** records.  The nameserver(s) must be configured to permit these
transactions.

When run at a time that no renewals are active, **acme\_token\_check** provides a means
to detect and remove leftover challenge tokens.  By default, it only generates output
if records are found or errors are encountered, making it suitable for a _cron_ job.
Such _cron_ jobs should be scheduled when they will not interfere with certificate
renewals.

**acme\_token\_check** can also scan for corresponding **CNAME** records, which are used
to redirect challenges to a dynamically-updatable domain.  These are usually static,
and should not be removed.

## SECURITY

Communications with the nameserver are signed with TSIG if **--tsig** is
specified.  Unsigned communications are adequate when TSIG is not used for
view selection, zone transfer authentication, or update authentication.

If TSIG is not used, the nameserver is presumed to handle any view selection,
and authentication based on IP address.  In this case, if the host running
**acme\_token\_check** is multi-homed, **--source-address** can be used to ensure
that transactions use an authorized address to communicate with the DNS servers.

## CHALLENGE REDIRECTION (CNAMES)

ACME issuer verification reaquires that the client have the ability to deposit challenge
tokens in the certificate's domain to prove ownership.  There are scenarios where,
due to security concerns, operational issues, or technical limitations, this is
inconvenient (or impossible).  To accomodate these scenarios, issuers may follow
CNAMEs for the challenge tokens to a server where the tokens can be installed, usually
by a form of dynamic update.  The CNAMEs are created in the certificate's domain, and
are static thereafter.

**acme\_token\_check** can generate these CNAMEs using the **--cnames-for** and **--target-zone** options.
The target will include a hash of the source domain, or the source domain name.  See **--hash**.

Installation is generally manual, but if the domain supports dynamic updates, you can use **--install**.
This is used when the certificate's domain restricts updates to designated people, who can
nonetheless benefit from **acme\_token\_check**'s automation.

## INITIALIZATION FILES

If the environment variable `ACME_TOKEN_CHECK` is defined, the file that it points to
is parsed before the command line.  It may contain options and/or domains.
Otherwise, **acme\_token\_check** looks for<.acme\_token\_check> in `.`,  `$HOME`, and
also for  `/etc/acme_token_check.conf`.
The first file found will be processed.  # comments are allowed.

**--init-file** specifies an initialization file to be used, and disables the automatic
search for `.acme_token_check`.

**--option**=_tag_ specifies that only lines matching the _tag_ are to be used.
Tags consist of a word followed by ':' at the beginning of a line.  Default is to
process only untagged lines.

These options are ignored in initialization files.

# EXAMPLES

Scan example.com (and all sub-domains) for tokens:

    acme_token_check example.com

Scan and delete:

    acme_token_check example.com --remove

Scan for CNAMEs (redirections)

    acme_token_check example.com --display=cnames

Scan and delete (remove implies display)

    acme_token_check example.com --remove=cnames

Generate the CNAME targeting dns.example.net for a wildcard certificate on host.example.com

     acme_token_check host.example.com --target=dns.example.net --cname='*'
    _acme-challenge.host.example.com. 1800 IN CNAME _acme-challenge.dns.example.net.

Generate CNAMEs for www.example.net, example.net, host2.example.net that
redirect to dns.example.net.  These will be unique with the cert. host in
the target name.  Use --hash for randomized hash names in the target name.

    acme_token_check --cnames="www,.,host2" example.net \
                     --target=dns.example.net
    _acme-challenge.host2.example.net. 1800 IN CNAME _acme-challenge.host2.example.net.dns.example.net.
    _acme-challenge.www.example.net. 1800 IN CNAME _acme-challenge.www.example.net.dns.example.net.
    _acme-challenge.example.net. 1800 IN CNAME _acme-challenge.example.net.dns.example.net.
    3 acme challenge cnames generated

    acme_token_check --cnames="www,.,host2" example.net \
                     --target=dns.example.net --hash=8
    _acme-challenge.www.example.net. 1800 IN CNAME _acme-challenge.a6ac7a77.dns.example.net.
    _acme-challenge.host2.example.net. 1800 IN CNAME _acme-challenge.c4f3ca34.dns.example.net.
    _acme-challenge.example.net. 1800 IN CNAME _acme-challenge.fff44f14.dns.example.net.
    3 acme challenge cnames generated

Generate the same CNAMEs, but all target a single server name.

    acme_token_check --cnames="www,.,host2" example.net \
                     --target=dns.example.net --nounique
    _acme-challenge.example.net. 1800 IN CNAME _acme-challenge.dns.example.net.
    _acme-challenge.host2.example.net. 1800 IN CNAME _acme-challenge.dns.example.net.
    _acme-challenge.www.example.net. 1800 IN CNAME _acme-challenge.dns.example.net.
    3 acme challenge cnames generated

Generate CNAMEs for www, mail, and webmail for example.us, example.info,
and example.fr. Since the nameserver supports RFC2136 dynamic update, install them.

    acme_token_check example.fr example.us example.info \
                     --cnames="www,mail,webmail"\
                     --target=dns.example.net --hash=8 --install \
                     --source-address=192.0.2.15
    _acme-challenge.mail.example.info. 1800 IN CNAME _acme-challenge.f220d62d.dns.example.net.
    _acme-challenge.webmail.example.info. 1800 IN CNAME _acme-challenge.aa6364c6.dns.example.net.
    _acme-challenge.www.example.info. 1800 IN CNAME _acme-challenge.5bfb0c72.dns.example.net.
    _acme-challenge.mail.example.fr. 1800 IN CNAME _acme-challenge.4314e798.dns.example.net.
    _acme-challenge.webmail.example.fr. 1800 IN CNAME _acme-challenge.95d60169.dns.example.net.
    _acme-challenge.www.example.fr. 1800 IN CNAME _acme-challenge.f827a766.dns.example.net.
    _acme-challenge.mail.example.us. 1800 IN CNAME _acme-challenge.764c032e.dns.example.net.
    _acme-challenge.webmail.example.us. 1800 IN CNAME _acme-challenge.6a3e68e9.dns.example.net.
    _acme-challenge.www.example.us. 1800 IN CNAME _acme-challenge.7b360ab3.dns.example.net.
    9 acme challenge cnames installed

Scan and delete tokens in all zones served by a BIND nameserver, except reverse zones.

    acme_token_check --named-address=dns3.example.net:8053  --view=external
                     --remove --tsig-key=/etc/my.key

# RETURN VALUE

The exit code provides summary status.  Values are ORed if more than one applies.

- 0 Success
- 1 A zone transfer failed.
- 2 A challenge token record was found.
- 4 A DNS server refused to delete a challenge token record.
- 8 A DNS server did not return a reply to a delete request.
- 16 A challenge token CNAME was found.
- 32 A DNS server refused to add a challenge CNAME.
- 64 A DNS server did not return a reply to a request to add a CNAME.
- 128 A query to obtain the primary server for a zone faile.
- 255 Error in command or unhandled error from a module.

# BUGS

Report any bugs, feature requests and/or patches on the issue tracker,
located at `https://github.com/tlhackque/certtools/issues`.  In the
event that the project moves, contact the author directly.

_Net::DNS_ prevents efficient connection reuse when **--recurse** is
used.  See [RT#145835](https://rt.cpan.org/Ticket/Display.html?id=145835)
Work-around adjusts timing at the cost of some memory.

# AUTHOR

Timothe Litt  <litt@acm.org>

# COPYRIGHT and LICENSE

Copyright (c) 2021-2024 Timothe Litt

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

_mod\_md_ _getssl_ _uacme_ _RFC8555_ ...

_POD version $Id$_
