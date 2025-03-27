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
     DHT: 10.5555/646334.687801

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

The Agent Directory Service (ADS) provides a mechanism for discovering AI agent
applications based on their capabilities. It uses a distributed directory
architecture to map agent skills to directory record identifiers and maintains a
list of directory servers hosting those records.

Directory records are identified by globally unique names that are routable
within a DHT (Distributed Hash Table) to locate peer directory servers.
The skill taxonomy is also routable in the DHT to map skillsets to records
that announce those skills.

Each directory record includes skills from a defined taxonomy, as specified
in the [Taxonomy of AI Agent Skills] from [OASF]. While all record data is
modeled using [OASF], only skills are leveraged for content routing in the
distributed network of directory servers.

This document describes the core concepts and architecture of the Agent
Directory Service.

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

ADS uses libp2p [Kad-DHT] [DHT] for server and content discovery.

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
