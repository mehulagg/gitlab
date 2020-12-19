# Troubleshooting the path from A to B

Networking allows computers to communicate with one another.

Connecting to GitLab requires being connected to a network on which a GitLab host or server is running.

## Intro & Technical Jargon

Open Systems Interconnection (OSI) Model and TCP/IP Stack.

## Tools

The following tools are helpful in troubleshooting networking issues.

### Can A connect to B?

#### ping

Ping host:

`ping {{host}}`

Ping a host only a specific number of times:

`ping -c {{count}} {{host}}`

Ping host, specifying the interval in seconds between requests (default is 1 second):

`ping -i {{seconds}} {{host}}`

#### traceroute

Print the route packets trace to network host.

Traceroute to a host:

`traceroute {{host}}`

Disable IP address and host name mapping:

`traceroute -n {{host}}`

#### curl

Transfers data from or to a server. [More information](https://curl.haxx.se).

Download the contents of an URL to a file:

`curl <http://example.com> -o <filename>`

Download a file, saving the output under the filename indicated by the URL:

`curl -O <http://example.com/filename>`

#### mtr

Matt's Traceroute: combined traceroute and ping tool. More information: [https://bitwizard.nl/mtr](https://bitwizard.nl/mtr).

Traceroute to a host and continuously ping all intermediary hops:

`mtr <host>`

Disable IP address and host name mapping:

`mtr -n <host>`

Generate output after pinging each hop 10 times:

`mtr -w <host>`

Force IP IPv4 or IPV6:

`mtr -4 <host>`

Wait for a given time (in seconds) before sending another packet to the same hop:

`mtr -i <seconds> <host>`

#### tracepath

traces path to destination

### What is running and on which ports?

#### netstat

Print network connections, routing tables,

#### ss

similar to netstat, used to dump network and socket statistics.

### DNS

DNS is a networking phonebook that translates domains to IP addresses.

#### dig

DNS Lookup utility.

Lookup the IP(s) associated with a hostname (A records):

`dig +short <example.com>`

Lookup the mail server(s) associated with a given domain name (MX record):

`dig +short <example.com> MX`

Get all types of records for a given domain name:

`dig <example.com> ANY`

Specify an alternate DNS server to query:

`dig @<8.8.8.8> <example.com>`

Perform a reverse DNS lookup on an IP address (PTR record):

`dig -x <8.8.8.8>`

Perform iterative queries and display the entire trace path to resolve a domain name:

`dig +trace <example.com>`

#### nslookup

Query name server(s) for various domain records.

Query your system's default name server for an IP address (A record) of the domain:

`nslookup <example.com>`

Query a given name server for a NS record of the domain:

`nslookup -type=NS <example.com> <8.8.8.8>`

Query for a reverse lookup (PTR record) of an IP address:

`nslookup -type=PTR <54.240.162.118>`

Query for ANY available records using TCP protocol:

`nslookup -vc -type=ANY <example.com>`

### What's going on the network?

#### tcpdump

Dump traffic on a network. More information: [tcpdump.org](https://www.tcpdump.org).

Capture the traffic of a specific interface:

`tcpdump -i <eth0>`

Capture the traffic from or to a host:

`tcpdump host <www.example.com>`

Capture the traffic from a specific interface, source, and destination port:

`tcpdump -i <eth0> src <192.168.1.1> and dst <192.168.1.2> and dst port <80>`

Capture the traffic of a network:

`tcpdump net <192.168.1.0/24>`

#### ngrep

Filter network traffic packets using regular expressions. More information: [https://github.com/jpr5/ngrep](https://github.com/jpr5/ngrep).

Capture traffic of all interfaces:

`ngrep -d any`

Capture traffic of a specific interface:

`ngrep -d <eth0>`

Capture traffic crossing port 22 of interface eth0:

`ngrep -d <eth0> port <22>`

Capture traffic from or to a host:

`ngrep host <www.example.com>`

#### nethogs

Net top tool grouping bandwidth per process

### Other

#### iptables

firewalls n such

#### ip

network interface information and configuration

### Encryption 

The S in HTTPS stands for Secure. It's secure because it's encrypted. 

Encryption at the network level uses Public Key Infrastructure to establish trusted connections and prevent transmitting data in plaintext. This includes certificates, certificate authorities, certificate trust stores, and more!

See SSL Troubleshooting Guide
