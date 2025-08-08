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

Multi-Agent Systems (MAS) represent a new paradigm in distributed computing
where software components leverage Large Language Models (LLMs) to perform
specialized tasks and solve complex problems through collaborative intelligence.
These systems combine LLMs with contextual knowledge and tool-calling
capabilities, often abstracted through Model Context Protocol (MCP) servers,
enabling dynamic workflows that adapt based on stored state and environmental
conditions.

The diversity and complexity of MAS architectures present unique challenges for
discovery and composition. As the ecosystem of AI agents expands, developers
need efficient mechanisms to:

- **Discover compatible agents** with specific skills and capabilities
- **Evaluate performance characteristics** including cost, latency, and resource
requirements
- **Compose multi-agent workflows** by linking agents with
complementary capabilities
- **Verify claims** about agent performance and reliability
- **Track versioning and dependencies** between agent components

The Agent Directory Service (ADS) addresses these challenges by providing a
distributed directory infrastructure specifically designed for the agentic AI
ecosystem. Rather than attempting to formally define MAS architectures, which
would constrain the creative composition patterns emerging in this rapidly
evolving field—ADS focuses on providing flexible metadata storage and discovery
mechanisms.

## Core Capabilities

ADS enables several key capabilities for the agentic AI ecosystem:

**Capability-Based Discovery**:
Agents publish structured metadata describing their functional abilities, costs,
and performance characteristics. The system organizes this information using
hierarchical skill taxonomies, enabling efficient matching of capabilities to
requirements.

**Verifiable Claims**:
While agent capabilities are often subjectively evaluated, ADS provides
cryptographic mechanisms for data integrity and provenance tracking. This allows
users to make informed decisions about agent selection while enabling reputation
systems to emerge organically.

**Semantic Linkage**:
Components can be securely linked to create various relationships like version
histories for evolutionary development, collaborative partnerships where
complementary skills solve complex problems, and dependency chains for composite
agent workflows.

**Distributed Architecture**:
Built on proven distributed systems principles, ADS uses content-addressing for
global uniqueness and implements distributed hash tables (DHT) for scalable
content discovery across decentralized networks.

## Architectural Foundation

The system leverages the Open Agentic Schema Framework (OASF) to model agent
information in a structured, extensible format. OASF enables rich queries such
as "What agents can solve problem A?" or "What combination of skills and costs
optimizes for task B?" This schema-driven approach supports both objective
metrics (token consumption, GPU requirements) and subjective evaluations (user
ratings, task completion quality).

Agent records are organized using modular extensions—reusable components like
MCP server definitions, prompt-based agents, and evaluation metrics. This
modular approach facilitates composition and reuse across different MAS
architectures while maintaining flexibility for innovative use cases.

The underlying storage layer integrates with OCI (Open Container Initiative)
standards, enabling interoperability with existing container ecosystems and
leveraging mature tooling for content distribution and verification.

This document details the technical architecture of ADS, covering the record
storage layer, security model, distributed data discovery mechanisms, and data
distribution protocols between storage nodes.

# Storage Architecture

ADS implements a decentralized storage architecture built on OCI (Open Container
Initiative) registries using ORAS (OCI Registry as Storage) as the foundational
object storage layer. This design choice enables the system to leverage mature,
standardized container registry infrastructure while achieving the speed,
scalability, and security requirements of a distributed agent directory.

## Content-Addressed Storage

The storage architecture centers on globally unique Content Identifiers (CID)
that provide several critical properties for a distributed agent directory:

**Immutability**: Content identifiers are cryptographically derived from the data they represent, ensuring that any modification results in a different identifier. This property is essential for maintaining data integrity in agent records and enabling verifiable claims about agent capabilities.

**Deduplication**: Identical content automatically receives the same identifier across all nodes in the network, eliminating storage redundancy and reducing bandwidth requirements when the same agent components are referenced by multiple systems.

**Verifiability**: Any node can independently verify that received content matches its identifier, providing built-in protection against data corruption or tampering during transmission.

**Location Independence**: Content can be retrieved from any node that possesses it, as the identifier serves as a universal pointer that abstracts away physical storage locations.

## ORAS Integration

ORAS provides a standardized interface for treating OCI registries as general-purpose object storage, offering several advantages for ADS:

### Standards Compliance

By building on OCI specifications, ADS inherits compatibility with the extensive ecosystem of container registry tools, security scanners, and management platforms. This includes:

- **Authentication and authorization** mechanisms already deployed in enterprise environments
- **Content signing and verification** through tools like Notary and cosign
- **Vulnerability scanning** capabilities that can be extended to agent security assessments
- **Content delivery networks** optimized for OCI artifact distribution

### Artifact Organization

Agent records are stored as OCI artifacts with a structured organization. Multiple records can be stored under the same OCI name and tag, with each record uniquely identified by its content-addressed SHA256 digest:

~~~
null_repo/records/
├── skills/
│   ├── nlp/
│   │   ├── sentiment-analysis:v1.0.0@sha256:abc123... # BERT
│   │   ├── sentiment-analysis:v1.0.0@sha256:def456... # RoBERTa
│   │   ├── sentiment-analysis:v1.0.0@sha256:ghi789... # DistilBERT
│   │   ├── text-classification:v2.0.0@sha256:abc123... # Same BERT
│   │   └── emotion-detection:v1.5.0@sha256:abc123...   # Same BERT
│   ├── vision/
│   │   ├── object-detection:v2.1.0@sha256:jkl012...    # YOLO
│   │   ├── object-detection:v2.1.0@sha256:mno345...    # R-CNN
│   │   └── scene-understanding:v1.0.0@sha256:jkl012... # Same YOLO
│   └── reasoning/
│       └── mathematical:v1.5.0@sha256:pqr678...
├── evaluations/
│   ├── performance-metrics:latest@sha256:stu901...
│   └── benchmark-results:v1.0.0@sha256:vwx234...
└── compositions/
    ├── security-analyst:v3.0.0@sha256:yza567...
    └── research-assistant:v2.2.0@sha256:bcd890...
~~~

This naming scheme demonstrates that the same content identifier can belong to
multiple skills, reflecting the reality that many AI agents are multi-capable.
For example, the BERT-based agent (`sha256:abc123...`) appears under multiple
skill categories: `nlp/sentiment-analysis`, `nlp/text-classification`, and
`nlp/emotion-detection`, representing different capabilities of the same
underlying agent implementation. Similarly, the YOLO vision model
(`sha256:jkl012...`) provides both `object-detection` and `scene-understanding`
capabilities.

This cross-referencing approach allows agents to be discovered through any of
their supported capabilities while maintaining unique addressability through
content identifiers. Each skill category can have its own versioning and
metadata, enabling fine-grained capability management even when multiple skills
share the same underlying implementation.

Each artifact contains structured metadata following OASF schemas, enabling rich
queries and capability matching across all variants within a given category.

### Multi-Registry Federation

The architecture supports federation across multiple registry instances, enabling:

- **Organizational boundaries**: Different organizations can maintain their own registries while participating in the global directory
- **Geographic distribution**: Content can be replicated to registries closer to consumers, reducing latency
- **Specialization**: Registries can focus on specific domains (e.g., medical AI agents, financial analysis tools)
- **Redundancy**: Critical agent records can be replicated across multiple registries for availability

## Decentralized Indexing

While individual records are stored in OCI registries, the system maintains decentralized indexes for efficient discovery:

### Content Index Structure

The content index maintains OASF-compliant metadata for efficient discovery. Examples of indexed records following the OASF schema:

~~~
{
  "content_id": "sha256:abc123...",
  "record": {
    "name": "BERT Sentiment Analyzer",
    "version": "1.0.0",
    "schema_version": "0.2.0",
    "description": "Multi-capability NLP agent providing sentiment analysis, text classification, and emotion detection",
    "skills": ["natural_language_processing"],
    "domains": ["finance_and_business", "trust_and_safety"],
    "capabilities": {
      "threads": true,
      "interrupt_support": false,
      "callbacks": true,
      "streaming": ["text", "json"]
    }
  },
  "performance_metrics": {
    "tokens_per_second": 1000,
    "gpu_memory_mb": 4096,
    "latency_p99_ms": 150,
    "accuracy_score": 0.94
  },
  "evaluation_data": {
    "overall_rating": 4.2,
    "cost_per_million_tokens": 2.50
  },
  "registries": [
    "registry.example.com",
    "hub.agents.org"
  ],
  "last_updated": "2025-08-07T10:30:00Z"
}
~~~

~~~
{
  "content_id": "sha256:jkl012...",
  "record": {
    "name": "YOLO Vision Agent",
    "version": "2.1.0",
    "schema_version": "0.2.0",
    "description": "Computer vision agent for object detection and scene understanding",
    "skills": ["images_computer_vision"],
    "domains": ["transportation", "industrial_manufacturing"],
    "capabilities": {
      "threads": false,
      "interrupt_support": true,
      "callbacks": false,
      "streaming": ["image", "json"]
    }
  },
  "performance_metrics": {
    "inference_fps": 30,
    "gpu_memory_mb": 8192,
    "detection_accuracy_map": 0.89,
    "processing_latency_ms": 33
  },
  "evaluation_data": {
    "overall_rating": 4.7,
    "cost_per_image": 0.05
  },
  "registries": [
    "vision.agents.com",
    "registry.example.com"
  ],
  "last_updated": "2025-08-07T14:20:00Z"
}
~~~

~~~
{
  "content_id": "sha256:pqr678...",
  "record": {
    "name": "Mathematical Reasoning Agent",
    "version": "1.5.0",
    "schema_version": "0.2.0",
    "description": "Agent specialized in mathematical problem solving and analytical reasoning",
    "skills": ["analytical_skills", "tabular_text"],
    "domains": ["education", "finance_and_business"],
    "capabilities": {
      "threads": true,
      "interrupt_support": true,
      "callbacks": true,
      "streaming": ["text", "latex"]
    }
  },
  "performance_metrics": {
    "problems_per_minute": 12,
    "cpu_cores": 4,
    "memory_mb": 2048,
    "accuracy_on_gsm8k": 0.87
  },
  "evaluation_data": {
    "overall_rating": 4.5,
    "cost_per_problem": 0.10
  },
  "registries": [
    "math.agents.edu",
    "registry.example.com"
  ],
  "last_updated": "2025-08-07T16:45:00Z"
}
~~~

### Distributed Hash Table Integration

ADS uses a DHT overlay network to maintain these indexes across participating nodes:

- **Consistent hashing** distributes index entries across nodes based on content
identifiers
- **Replication factor** ensures index availability even when nodes leave the
network
- **Eventual consistency** propagates updates across the network while
maintaining performance
- **Query routing** efficiently locates relevant content without broadcasting to
all nodes

## Security Model

The OCI-based architecture provides multiple layers of security:

### Cryptographic Integrity

- **Content addressing** ensures tamper detection through cryptographic hash verification
- **Digital signatures** on artifacts provide authenticity guarantees using established PKI infrastructure
- **Supply chain security** through integration with software bill of materials (SBOM) tools

### Access Control

- **Registry-level permissions** control who can publish and retrieve agent
records
- **Fine-grained policies** can restrict access to specific agent categories or
capability types
- **Audit trails** leverage existing registry logging capabilities to track
access patterns

### Trust Boundaries

- **Organizational isolation** through separate registries maintains security boundaries
- **Content verification** allows nodes to validate artifact integrity without trusting transport layers
- **Reputation systems** can build on cryptographic proofs of past agent performance

## Performance Optimizations

The architecture incorporates several optimizations for the specific
requirements of agent discovery:

### Caching Strategy

- **Capability indexes** are cached at edge nodes for sub-second query response
- **Popular agent records** are automatically replicated to reduce retrieval latency
- **Negative caching** prevents repeated queries for non-existent capabilities

### Bandwidth Optimization

- **Incremental updates** use OCI layer semantics to transmit only changed portions of agent records
- **Content compression** reduces storage and transmission costs for large agent definitions
- **Selective replication** based on query patterns minimizes unnecessary data transfer

### Scalability Architecture

The system scales horizontally through several mechanisms:

- **Registry sharding** distributes storage load across multiple OCI registry instances
- **Index partitioning** in the DHT allows query load to scale with the number
of participating nodes
- **Lazy loading** defers retrieval of detailed agent specifications until actually needed

This architecture provides a robust foundation for a decentralized agent
directory that can scale to support the growing ecosystem of AI agents while
maintaining the security and reliability requirements of production systems.

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



# IANA Considerations

This document has no IANA actions.

--- bac

# Acknowledgments
{:numbered="false"}
