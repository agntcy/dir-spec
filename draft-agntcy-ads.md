---
###
# Description of Agent Directory Service
###

title: "Agent Directory Service"
abbrev: "agent-dir"
category: info

docname: draft-agntcy-ads-latest
submissiontype: independent
number:
date:
consensus: false
v: 3
area: Applications
workgroup: Independent Submission
keyword:
 - AI
 - Agentic AI
 - Directory Protocol
 - Agent Discovery
 - DHT
venue:
  group: WG
  type: Working Group
  mail: discussion@agntcy.org
  github: agntcy/dir
  latest: https://verbose-adventure-1pnqvyr.pages.github.io/

author:
 -
    fullname: Luca Muscariello
    organization: Cisco
    email: lumuscar@cisco.com


informative:

--- abstract

This document specifies a protocol for announcing and discovering AI agents in a
distributed system using the Open Agentic Schema Framework (OASF). The Agent
Directory Protocol enables agents to advertise their capabilities through
attribute-based taxonomies and discover other agents based on their skills. The
protocol leverages a Distributed Hash Table (DHT) for storing and retrieving
agent directory records.

--- middle


# Conventions and Definitions

{::boilerplate bcp14-tagged}



# Introduction

As AI systems become more prevalent, there is an increasing need for agents to
discover and interact with each other dynamically based on their capabilities.
The Agent Directory Protocol provides a standardized way for agents to:

* Announce their presence using OASF attribute taxonomies
* Discover other agents based on required skills and attributes
* Maintain distributed directory information in a DHT
* Enable attribute-based routing and discovery

The protocol is designed to be fully distributed, extensible, and secure while
supporting the dynamic nature of agentic AI systems.

# Protocol Overview

## OASF Attributes

The protocol uses OASF to define attribute taxonomies that describe agent capabilities. These attributes fall into categories such as:

* Skills and competencies
* Domain knowledge
* Interaction patterns
* Security propertion
Attributes are organized hierarchically and can be extended to support new capabilities.



### Content digest

The content digest MUST be generated using a. The purpose of the digest is to
serve as a **global identifier of arbitrary data** on the storage layer. An
example of calculating content digest in Golang using SHA-256 hashing function
can be found in
[go-cid](https://github.com/ipfs/go-cid#creating-a-cid-from-scratch) package.

The current implementation of the Directory uses CID as a default standard when
dealing with content digests. See more in the [Content
Identity](https://github.com/multiformats/cid) specs.

## Network

The Directory network MUST use a cryptographically strong identity.
A "dir node" is a program that can publish, find, and replicate objects across the network.
Its identity is defined by a private key.

The node MAY be allowed to work in one of the following **modes of operation**:
- **client** -- The node can interact with the public network, but it does not expose any interfaces to it.
The interfaces can be exposed only to the local network.
- **swarm** -- The node exposes all its interfaces to a subset of nodes on the network.
- **server** -- The node exposes all its interfaces to the public network.

All interfaces and operations on the network MUST be provided and performed by the node itself.


## DHT-based Directory

Agent directory records are stored in a DHT with the following properties:

* Records are indexed by attribute combinations
* Support for partial and wildcard attribute matching
* Built-in replication and fault tolerance
* Decentralized operation with no single point of failure

### Routing Tables

~~~
        +------+
        | Node |
        +------+
         /    \
        /      \
  +--------+  +--------+
  | Agents |  | Skills |
  +--------+  +--------+
       |           |
       |           |
  +---------+  +-------------+
  |  Alice  |  |  TextSummary|
  +---------+  +-------------+
       |           |
       |           |
  +-------------+  +-------------+
  | /dir/CID-   |  | /dir/CID-   |
  | Alice-v1    |  | Bob-v1      |
  +-------------+  +-------------+
       |
       |
  +-------------+
  |  Bob        |
  +-------------+
       |
       |
  +-------------+
  | /dir/CID-   |
  | Bob-v2      |
  +-------------+
~~~

{: #fig-routing title="Routing Example."}

Clients SHOULD first query the Skill Routing Table to find which agents have a
given skill, and then query the releases for a given agent using the Agent
Routing Table.

Note that each skill only points to the agent name (or subgraph) rather than
having all the digests for all agents. This is to prevent creating record
duplications between the two graphs. An agent with a given skill can be
traversed using Agent Routing table once we know that the given agent has a
release that contains a given skill.


## Routing

Implementations MUST expose a **routing interface** that allows the
**announcement and discovery** of agent records across the network. The routing
layer serves two important purposes:

- peer routing -- to find and connect with other nodes on the network
- content routing -- to find the data published across the network

The routing system can be satisfied with various kinds of implementations. The
current implementation of the Directory uses DHT (distributed hash table) for
routing. See more in the [libp2p](https://github.com/libp2p/specs) specs. The
interface currently used across the system is defined in
[api/routing](api/routing).

### Announcement

The nodes participating in the network MUST be able to **receive the
announcement events** when the new data is published to the network to be able
to update their routing tables. Nodes MAY also optionally pull the data if
needed from the node that sent the event.

The minimal interface required to implement the Announcement API consists of a
method that broadcasts locally available Agent data models to the rest of the
network. For example, `Announce(node routing.Node, model core.ObjectRef)`.

### Discovery

The nodes participating in the network MUST be able to **find published
contents**. The minimal interface required to implement the Discovery API
consists of two sub-interfaces for querying and traversing the objects on a
given node based on:

- **Discovery By Name**
  - `List(path=/agents)` -- returns a list of unique agent names
  - `List(path=/agents/{agent})` -- returns a list of all release digests
    associated with a given agent

- **Discovery By Skill**
  - `List(path=/skills)` -- returns a list of unique skill names
  - `List(path=/skills/{skill})` -- returns a list of unique agent names that
    have a release with a given skill

Implementations MAY allow more granular querying logic for the Discovery API.

# Security Considerations

The Agent Directory Protocol relies on several security mechanisms to ensure the
integrity and authenticity of directory records:

## Record Signatures

All agent directory records MUST be digitally signed by the producing agent. The
signature covers:

* The complete set of OASF attributes
* The agent's capabilities description
* Any additional metadata

Signatures enable consumers to verify the authenticity and integrity of records
independent of their location in the DHT.

## Location Independence

Agent directory records are location-independent - their trust is derived from
cryptographic signatures rather than network location. This means:

* Records can be cached and replicated across the DHT
* Consumers can verify records regardless of the serving node
* Man-in-the-middle attacks are prevented through signature verification

## Key Management

Agents MUST generate and maintain cryptographic key pairs following these
requirements:

* Use of asymmetric cryptography (e.g., Ed25519)
* Private keys MUST be properly secured by agents
* Public keys are distributed as part of agent records
* Key rotation procedures MUST be supported

## DHT Security

The DHT implementation MUST provide:

* Node authentication to prevent Sybil attacks
* Secure routing to prevent record tampering
* Replication policies to ensure availability
* Access controls for record updates

## Transport Security

All protocol interactions MUST use secure transport with:

* Mutual authentication between nodes
* Perfect forward secrecy

Implementations MUST NOT support plaintext communications.


# IANA Considerations

This document has no IANA actions.

--- back

# Acknowledgments
{:numbered="false"}
