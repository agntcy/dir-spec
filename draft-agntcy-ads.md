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
  github: agntcy/dir
  latest: https://spec.dir.agncty.org

author:
 -
    fullname: Luca Muscariello
    organization: Cisco
    email: lumuscar@cisco.com
 -
    fullname: Ramiz Polic
    organization: Cisco
    email: rpolic@cisco.com

normative:
   RFC6920:

informative:
   DHT: DOI.10.5555/646334.687801

--- abstract

The Agent Directory Service (ADS) is a distributed directory service designed to
store metadata for AI agent applications. This metadata, stored as directory
records, enables the discovery of agent applications with specific skills for
solving various problems. The implementation features distributed directories
that interconnect through a content-routing protocol.

--- middle

# Conventions and Definitions

{::boilerplate bcp14-tagged}

# Introduction

Multi-Agent Systems (MAS) represent a new paradigm in distributed computing where software components leverage Large Language Models (LLMs) to perform specialized tasks and solve complex problems through collaborative intelligence. These systems combine LLMs with contextual knowledge and tool-calling capabilities, often abstracted through Model Context Protocol (MCP) servers, enabling dynamic workflows that adapt based on stored state and environmental conditions.

The diversity and complexity of MAS architectures present unique challenges for discovery and composition. As the ecosystem of AI agents expands, developers need efficient mechanisms to:

- **Discover compatible agents** with specific skills and capabilities
- **Evaluate performance characteristics** including cost, latency, and resource requirements
- **Compose multi-agent workflows** by linking agents with complementary capabilities
- **Verify claims** about agent performance and reliability
- **Track versioning and dependencies** between agent components

The Agent Directory Service (ADS) addresses these challenges by providing a distributed directory infrastructure specifically designed for the agentic AI ecosystem. Rather than attempting to formally define MAS architectures—which would constrain the creative composition patterns emerging in this rapidly evolving field—ADS focuses on providing flexible metadata storage and discovery mechanisms.

## Core Capabilities

ADS enables several key capabilities for the agentic AI ecosystem:

**Capability-Based Discovery**: Agents publish structured metadata describing their functional abilities, costs, and performance characteristics. The system organizes this information using hierarchical skill taxonomies, enabling efficient matching of capabilities to requirements.

**Verifiable Claims**: While agent capabilities are often subjectively evaluated, ADS provides cryptographic mechanisms for data integrity and provenance tracking. This allows users to make informed decisions about agent selection while enabling reputation systems to emerge organically.

**Semantic Linkage**: Components can be securely linked to create various relationships—version histories for evolutionary development, collaborative partnerships where complementary skills solve complex problems, and dependency chains for composite agent workflows.

**Distributed Architecture**: Built on proven distributed systems principles, ADS uses content-addressing for global uniqueness and implements distributed hash tables (DHT) for scalable content discovery across decentralized networks.

## Architectural Foundation

The system leverages the Open Agentic Schema Framework (OASF) to model agent information in a structured, extensible format. OASF enables rich queries such as "What agents can solve problem A?" or "What combination of skills and costs optimizes for task B?" This schema-driven approach supports both objective metrics (token consumption, GPU requirements) and subjective evaluations (user ratings, task completion quality).

Agent records are organized using modular extensions—reusable components like MCP server definitions, prompt-based agents, and evaluation metrics. This modular approach facilitates composition and reuse across different MAS architectures while maintaining flexibility for innovative use cases.

The underlying storage layer integrates with OCI (Open Container Initiative) standards, enabling interoperability with existing container ecosystems and leveraging mature tooling for content distribution and verification.

This document details the technical architecture of ADS, covering the record storage layer, security model, distributed data discovery mechanisms, and data distribution protocols between storage nodes.



# Naming

In distributed systems, a reliable and collision-resistant naming scheme is
crucial. The agent directory uses cryptographic hashes {{!RFC7838}} to generate
globally unique identifiers for data records.

ADS leverages OCI as object storage, and therefore identifiers are made
available as described in [OCI digest].

# Content Routing

ADS implements capability-based record discovery through a hierarchical
skill taxonomy. This architecture enables:

## Capability Announcement

Multi-agent systems publish their capabilities by encoding them as skill
taxonomies. Each record contains metadata describing the agent's functional
abilities. Skills are structured in a hierarchical format for efficient
matching.

## Discovery Process

The system performs a two-phase discovery operation:

1. Matches queried capabilities against the skill taxonomy to determine records
   by their identifier
2. Identifies the server nodes storing relevant records.

 ## Distributed Resolution

 Local nodes execute targeted retrievals based on:

1. Skill matching results: Evaluates capability requirements.
2. Server location information: Determines optimal data sources.

ADS uses libp2p [Kad-DHT] {{DHT}} for server and content discovery.



~~~
                             +----------------+
                             |    DHT Node    |
                             | Content Index  |
                             +----------------+
                                    ^
                                    |
                   +----------------+-----------------+
                   |                |                |
           +-------v------+  +------v-------+  +-----v--------+
           | Server Node A |  | Server Node B|  | Server Node C|
           |   Content X  |  |   Content Y  |  |   Content Z  |
           +-------+------+  +------+-------+  +------+-------+
                   |               |                  |
                   |        Content Exchange          |
                   +---------------+------------------+
                                  |
                          Content Replication

Flow:
1. Servers register content with DHT
2. DHT maintains content-to-server mappings
3. Servers query DHT to locate content
4. DHT returns list of servers hosting content
5. Servers download content from peers
~~~

## Distributed Object Storage

ADS differs from block storage systems like [IPFS] in its approach to
distributed object storage.

### Simplified Content Retrieval

1. ADS directly stores complete records rather than splitting them into blocks.
2. No special optimizations are needed for retrieving content from multiple
   sources.
3. Records are retrieved as complete units using standard OCI protocols.

### OCI Integration

ADS leverages the OCI distribution specification for content storage and
retrieval:

1. Records are stored and transferred using OCI artifacts.
2. Any OCI distribution-compliant server can participate in the network.
3. Servers retrieve records directly from each other using standard OCI
   protocols.

While ADS uses zot as its reference OCI server implementation, the system works
with any server that implements the OCI distribution specification.

# IANA Considerations

This document has no IANA actions.

--- bac

# Acknowledgments
{:numbered="false"}
