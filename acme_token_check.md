# ACME\_TOKEN\_CHECK

acme\_token\_check - check DNS domain(s) for stray ACME tokens

# SYNOPSIS

acme\_token\_check \[options\] \[domain ...\]

    Options
      --debug           --library   --nameservers  --recurse  --remove
      --source-address  --tsig-key  --unsigned     --verbose  --view
      --help            --man       --version

If no domain is specified, all domains in `%TL::Netconfig::domains` are checked,
except for any in `.arpa` or `localhost`.

# OPTIONS

- **-d** **--\[no\]debug**

    Display debugging output from DNS queries.

- **--library**=_path_

    Library path for PerlLib modules.

- **--nameservers**-_addr,..._

    Name(s) and/or Address(es) of nameservers to use.

- **--\[no\]recurse**

    Process delegations (subzones) of the specified domains.  Default is **--recurse**,

- **-r** **--\[no\]remove**

    Remove all records found.  Default is **--noremove**.

- **-s** **--source-address**=_address_

    Send queries from _address_.  Default is any local address.

- **-k** **--tsig-key**=_file_

    Specify a file containing TSIG key to use for the domain(s).

    Default is to use the 'external' key specified in `TL::NetConfig`.

- **-u** **--unsigned**

    Do not sign queries or updates with TSIG.

- **-V** **--view**=_name_

    Specify view to be used if **--tsig-ky** is defaulted.

- **-v** **--\[no\]verbose**

    Report all findings/actions.

    Default is to report totals if any records are found, and to report errors.

- **--help**

    Print a brief help message and exit.

- **--man**

    Print the manual page and exit.

# DESCRIPTION

**acme\_token\_check** scans the specified domain(s) and any subdomains for **TXT** records
of the form:

    _acme-challenge.*

With **--verbose** tnose found will be reported.

With **--remove**, those found will be removed from the DNS.

These records are created when the ACME protocol is used to obtain TLS certificates.,
validating domain ownership with its _DNS-01_ option.

They should be removed, but system or software failures can leave them in the DNS.

**acme\_token\_check** performs a zone transfer (AXFR) in order to locate the
text records.  If requested, it uses DNS UPDATE to remove them.  The nameserver
must be configured to permit these transactions.

When run at a time that no renewals are active, **acme\_token\_check** provides a means
to detect and remove leftover challenge records.  By default, it only generates output
if records are found or errors are encountered, making it suitable for a _cron_ job.
Such _cron_ jobs should be scheduled when they will not interfere with certificate
renewals.

Communications with the nameserver are signed with TSIG unless **--unsigned** is
specified.  **--unsigned** communications are adequate when TSIG is not used for
view selection, zone transfer authentication, or update authentication.

If TSIG is not used, the nameserver is presumed to handle any view selection,
and authentication based on IP address.  In this case, if the host running
**acme\_token\_check** is multi-homed, **--source-address** can be used to ensure
that transactions use an authorized address to communicate with the DNS servers.

**PerlLib** is a non-public library.  It is not required if a domain, **--nameserver**
and **--tsig-key** (or **--unsigned**) are specified.  Otherwise, **acme\_token\_check** will
try to load modules from PerlLib to obtain defaults for these options.

# RETURN VALUE

The exit code provides summary status.  Values are ORed if more than one applies.

- 0 Success
- 1 A zone transfer failed.
- 2 A challenge token record was found.
- 4 A DNS server refused to delete a challenge token record.
- 8 A DNS server did not return a reply to a delete request.
- 255 Error in command or unhandled error from a module.

# BUGS

Report any bugs, feature requests and/or patches on the issue tracker,
located at `https://github.com/tlhackque/certtools/issues`.  In the
event that the project moves, contact the author directly.

_Net::DNS_ prevents efficient connection reuse when **--recurse** is
used.  See [RT#145835](https://rt.cpan.org/Ticket/Display.html?id=145835)
Work-around adjusts timing at the cost of some memory.

# AUTHOR

Timothe Litt  &lt;litt@acm.org>

# COPYRIGHT and LICENSE

Copyright (c) 2023 Timothe Litt

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
