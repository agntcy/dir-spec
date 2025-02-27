---
###
title: "Agent Directory Protocol"
abbrev: "agent-dir"
category: info

docname: draft-muscariello-agent-directory-latest
submissiontype: independent
number:
date:
consensus: true
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
  group: Independent Submission
  type: Working Group
  mail: discussion@agntcy.org
  github: muscariello/agent-directory
  latest: https://example.org/latest

author:
 -
    fullname: Luca Muscariello
    organization: Cisco
    email: lumuscar@cisco.com

normative:
  RFC2119:
  RFC8174:
  RFC6120:

informative:
  RFC7650:
  I-D.irtf-din-agentic:

--- abstract

This document specifies a protocol for announcing and discovering AI agents in a
distributed system using the Open Agentic Schema Framework (OASF). The Agent
Directory Protocol enables agents to advertise their capabilities through
attribute-based taxonomies and discover other agents based on their skills. The
protocol leverages a Distributed Hash Table (DHT) for storing and retrieving
agent directory records.

--- middle

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

The protocol uses OASF to define attribute taxonomies that describe agent capabilities.
These attributes fall into categories such as:

* Skills and competencies
* Domain knowledge
* Interaction patterns
* Security properties

Attributes are organized hierarchically and can be extended to support new capabilities.

## DHT-based Directory

Agent directory records are stored in a DHT with the following properties:

* Records are indexed by attribute combinations
* Support for partial and wildcard attribute matching
* Built-in replication and fault tolerance
* Decentralized operation with no single point of failure


# Conventions and Definitions

{::boilerplate bcp14-tagged}


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

Agents MUST generate and maintain cryptographic key pairs following these requirements:

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

