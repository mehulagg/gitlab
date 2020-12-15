# Troubleshooting the path from A to B

Networking allows computers to communicate with one another.

Connecting to GitLab requires being connected to a network on which a GitLab host or server is running.

## Intro & Technical Jargon

OSI Model / TCP/IP Stack, Yadda Yadda

## Tools

The following tools can come in handy when troubleshooting networking issues.

### Can A connect to B?

#### ping

#### traceroute

#### mtr

#### tracepath

### curl

### What is running and on which ports?

#### netstat

#### ss

#### nmap

#### ip

### DNS

DNS is a networking phonebook that translates domains to IP addresses.

#### dig

#### nslookup

### What's going on here?

#### tcpdump

#### iptables

#### nethogs

#### ngrep

### Network encryption 

The S in HTTPS stands for Secure. It's secure because it's encrypted. 

Encryption at the network level uses Public Key Infrastructure to establish trusted connections and prevent transmitting data in plaintext. PKI includes certificates, certificate authorities, certificate trust stores, and more!

See SSL Troubleshooting Guide
