# Troubleshooting the path from A to B

Networking allows computers to communicate with one another.

Connecting to GitLab requires being connected to a network on which a GitLab host or server is running.

## Intro & Technical Jargon

Open Systems Interconnection (OSI) Model and TCP/IP Stack.

## Tools

The following tools are helpful in troubleshooting networking issues.

### Can A connect to B?

#### ping

sends request to target and reports back.

#### traceroute

print the route packets trace to network host

#### tracepath

traces path to destination

#### mtr

mtr combines the functionality of the traceroute and ping

### curl

### What is running and on which ports?

#### netstat

Print network connections, routing tables,

#### ss

similar to netstat, used to dump network and socket statistics.

#### nmap

### DNS

DNS is a networking phonebook that translates domains to IP addresses.

#### dig

#### nslookup

### What's going on the network?

#### tcpdump

captures packets

#### ngrep

tcpdump + grep

#### nethogs

Net top tool grouping bandwidth per process

### Other

#### iptables

firewalls n such

#### ip

network interface info and configuration

### Encryption 

The S in HTTPS stands for Secure. It's secure because it's encrypted. 

Encryption at the network level uses Public Key Infrastructure to establish trusted connections and prevent transmitting data in plaintext. This includes certificates, certificate authorities, certificate trust stores, and more!

See SSL Troubleshooting Guide
