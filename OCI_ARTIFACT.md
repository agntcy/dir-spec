# Record Artifact Specification

The specification defines an open standard for packaging and distribution of AGNTCY OASF Records as OCI artifacts, adhering to [the OCI image specification](https://github.com/opencontainers/image-spec/blob/main/spec.md#image-format-specification).

The goal of this specification is to enable the creation of interoperable solutions for packaging and retrieving of records by leveraging the existing OCI ecosystem, thereby facilitating efficient agent discovery, distribution, and integration in cloud-native environments.

**NOTE:** Record Artifact in the context of this specification refers to an AGNTCY OASF Record packaged as an OCI artifact.

## Use Cases

- **Distribution**: Packaging as OCI artifacts provides simple distribution through OCI-compliant registries, enabling easy sharing of records across different platforms and environments.
- **Compatibility** - The OCI manifest structure enables extensibility by allowing evolution of the Record Artifact and its schema structure over time, accommodating new requirements and features without breaking compatibility.
- **Versioning**: OCI artifacts support versioning, allowing for efficient management of different versions of records. This facilitates updates and rollbacks of agent definitions.
- **Readability** - Record Artifact is structured in a way that is both machine-readable (e.g., to perform quick lookups) and human-readable (e.g., to reconstruct the original record), making it easy to understand and work with the data.
- **Linkage** - OCI artifacts can reference other artifacts, enabling the creation of complex definitions that can include multiple components while maintaining clear relationships between them.
- **Discovery** - OCI registries provide a centralized location for storing and discovering Record Artifacts, making it easier for developers and systems to find and utilize agents.
- **Integrations** - By adhering to the OCI specification, Record Artifacts can easily integrate with existing systems and tools that leverage OCI standards.

## Overview

At a high level, the AGNTCY Record OCI Artifact Specification is based on the [OCI Image Format Specification](https://github.com/opencontainers/image-spec/blob/main/spec.md#image-format-specification) and incorporates [all its components](https://github.com/opencontainers/image-spec/blob/main/spec.md#understanding-the-specification).

## Specification

The Record Artifacts follows the [OCI Image Manifest Specification](https://github.com/opencontainers/image-spec/blob/main/manifest.md) and adheres to the [artifacts guidance](https://github.com/opencontainers/image-spec/blob/main/artifacts-guidance.md).

- `mediaType` string

  This REQUIRED property MUST be `application/vnd.oci.image.manifest.v1+json`, refer to the [Guidelines for Artifact Usage](https://github.com/opencontainers/image-spec/blob/main/artifacts-guidance.md).

- `artifactType` string

  This REQUIRED property MUST be `application/vnd.agntcy.oasf.record.v1+json`.
  Future versions of the Record Artifact Specification MAY define additional artifact types.

- `config` descriptor

  This REQUIRED property references a configuration object for a Record Artifact, by digest.

  - `mediaType` string

    This REQUIRED property MUST be `application/vnd.oci.empty.v1+json`.
    This indicates that no additional configuration data is needed for Record Artifacts.

- `layers` array of objects

  This REQUIRED property contains one or more layer descriptors representing OASF Record components. 

  - `mediaType` string

    This REQUIRED property specifies the layer content type. Implementations MUST support the following media types:

    - `application/vnd.agntcy.oasf.types.{version}.Record+json`: The first layer (index 0) MUST use this media type and contains base record data. 
    This layer MUST use the `data` field for inline storage (base64-encoded) since the content is small, frequently accessed, and unique to each record. When no additional component layers are present, this base layer contains a complete inline record with all OASF fields. The full record is reconstructed by merging data from subsequent component layers into the appropriate fields of the base record structure.

    - `application/vnd.agntcy.oasf.types.{version}.Skill+json`: The layer contains skill definition data.
    Data for `id` is stored as part of layer annotations.
    Other data is stored separately to allow for reuse across multiple records, ensuring that it is not duplicated in storage.

    - `application/vnd.agntcy.oasf.types.{version}.Domain+json`: The layer contains domain definition data.
    Data for `id` is stored as part of layer annotations.
    Other data is stored separately to allow for reuse across multiple records, ensuring that it is not duplicated in storage.

    - `application/vnd.agntcy.oasf.types.{version}.Locator+json`: The layer contains locator definition data, referencing the location where the agent can be accessed or deployed.
    Data for `type` and `url` is stored as part of layer descriptor annotations and URL fields.
    Other data is stored separately to allow for reuse across multiple records, ensuring that it is not duplicated in storage.
  
    - `application/vnd.agntcy.oasf.types.{version}.Module+json`: The layer contains module definition data.
    Data for `id` is stored as part of layer annotations.
    Other data is stored separately to allow for reuse across multiple records, ensuring that it is not duplicated in storage.

    Media types MUST map to `application/vnd.{schema_uri}.{version}.{type}+{encoding}` format, where:
      - `{schema_uri}` is `agntcy.oasf.types` and matches the OASF types protobuf package URI
      - `{version}` corresponds to a specific OASF types version (e.g., `v1alpha2`)
      - `{type}` is the OASF type name (e.g., `Record`, `Skill`, `Domain`, `Locator`, `Module`)
      - `{encoding}` suffix indicates the encoding format, which MUST be `json` for all OASF types
    
    The complete list of OASF types is defined in the [AGNTCY OASF Types Specification](https://github.com/agntcy/oasf/tree/main/proto/agntcy/oasf/types).

  - `data` string

    This OPTIONAL property contains base64-encoded layer content and MUST be present for the `Record` layer. The data field enables inline storage of base record fields directly within the manifest descriptor. For other layer types (Skill, Domain, Locator, Module), this field MUST NOT be used; the layer content is stored as a separate blob in the registry and referenced by the `digest` field.
    Record MUST be broken into multiple layer if it exceeds typical OCI Manifest size limits (e.g., >4MB).

  - `urls` array of strings

    This OPTIONAL property contains a single URL pointing to external resources, particularly useful for `Locator` layers to specify deployment target (e.g., `https://ghcr.io/agntcy/agent:latest` for docker-image locators).

  - `annotations` string-string map

    This OPTIONAL property contains arbitrary attributes for the layer. For metadata specific to AGNTCY objects, implementations SHOULD use the predefined annotation keys:

    - `agntcy.oasf.record/schema_version`: Reserved annotation for schema version (for `Record` layers)
    - `agntcy.oasf.record/created_at`: Reserved annotation for creation timestamp (for `Record` layers)
    - `agntcy.oasf.record/skill.id`: Reserved annotation for skill ID (for `Skill` layers)
    - `agntcy.oasf.record/domain.id`: Reserved annotation for domain ID (for `Domain` layers)
    - `agntcy.oasf.record/module.id`: Reserved annotation for module ID (for `Module` layers)
    - `agntcy.oasf.record/locator.type`: Reserved annotation for locator type (for `Locator` layers)

### Record Reconstruction

Applications consuming Record Artifacts MUST implement the following reconstruction algorithm to produce complete OASF Records:

1. **Pull Manifest**: Retrieve the OCI image manifest from the registry using standard [OCI Distribution API](https://github.com/opencontainers/distribution-spec) operations.

2. **Extract Base Record**: Parse the first layer (index 0) with media type `application/vnd.agntcy.oasf.types.{version}.Record+json`. Base64-decode the `data` field to obtain the base record JSON data.

3. **Retrieve Component Layers**: For each subsequent layer (Skill, Domain, Locator, Module):
   - Fetch the blob content from the registry using the layer's `digest`
   - Verify the blob's SHA-256 digest matches the descriptor's `digest` field
   - Parse the JSON content according to the layer's `mediaType`
   - Merge the component data into the appropriate field of the base record structure
   - Merge descriptor annotations into the corresponding component metadata

4. **Validate Schema**: Validate the reconstructed record against the OASF schema version specified in the `agntcy.oasf.record/schema_version` annotation.

For inline records (containing only the base Record layer), step 3 is skipped as all data is present in the base layer.

### Example Record Artifacts

**Layered Record**

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "artifactType": "application/vnd.agntcy.oasf.record.v1+json",
  "config": {
    "mediaType": "application/vnd.oci.empty.v1+json",
    "digest": "sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
    "size": 2
  },
  "layers": [
    {
      "mediaType": "application/vnd.agntcy.oasf.types.v1alpha2.Record+json",
      "data": "<BASE64_ENCODED_RECORD_DATA>",
      "digest": "sha256:d5815835051dd97d800a03f641ed8162877920e734d3d705b698912602b8c763",
      "size": 216,
      "annotations": {
        "agntcy.oasf.record/schema_version": "0.7.0",
        "agntcy.oasf.record/created_at": "2026-01-06T00:00:00Z"
      }
    },
    {
      "mediaType": "application/vnd.agntcy.oasf.types.v1alpha2.Skill+json",
      "digest": "sha256:3f907c1a03bf20f20355fe449e18ff3f9de2e49570ffb536f1a32f20c7179808",
      "size": 93,
      "annotations": {
        "agntcy.oasf.record/skill.id": "10201"
      }
    },
    {
      "mediaType": "application/vnd.agntcy.oasf.types.v1alpha2.Domain+json",
      "digest": "sha256:6d923539c5c208de77146335584252c0b1b81e35c122dd696fe6e04ed03d7411",
      "size": 46,
      "annotations": {
        "agntcy.oasf.record/domain.id": "101"
      }
    },
    {
      "mediaType": "application/vnd.agntcy.oasf.types.v1alpha2.Locator+json",
      "digest": "sha256:a5378e569c625f7643952fcab30c74f2a84ece52335c292e630f740ac4694146",
      "size": 106,
      "urls": [
        "https://ghcr.io/agntcy/agent:latest"
      ],
      "annotations": {
        "agntcy.oasf.record/locator.type": "docker-image"
      }
    },
    {
      "mediaType": "application/vnd.agntcy.oasf.types.v1alpha2.Module+json",
      "digest": "sha256:5e236ec37438b02c01c83d134203a646cb354766ac294e533a308dd8caa3a11e",
      "size": 6789371,
      "annotations": {
        "agntcy.oasf.record/module.id": "10201"
      }
    }
  ],
  "subject": {
    "mediaType": "application/vnd.oci.image.manifest.v1+json",
    "artifactType": "application/vnd.agntcy.oasf.record.v1+json",
    "digest": "sha256:7e346bc58473bc1d8a98776fa2a89a3e2a446b27f0e8a33ad49c3d4f28b6471d",
    "size": 702
  }
}
```

**Embedded Record**

```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "artifactType": "application/vnd.agntcy.oasf.record.v1+json",
  "config": {
    "mediaType": "application/vnd.oci.empty.v1+json",
    "digest": "sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
    "size": 2
  },
  "layers": [
    {
      "mediaType": "application/vnd.agntcy.oasf.types.v1alpha2.Record+json",
      "data": "<BASE64_ENCODED_RECORD_DATA>",
      "digest": "sha256:d5815835051dd97d800a03f641ed8162877920e734d3d705b698912602b8c763",
      "size": 1256,
      "annotations": {
        "agntcy.oasf.record/schema_version": "0.7.0",
        "agntcy.oasf.record/created_at": "2026-01-06T00:00:00Z"
      }
    }
  ],
  "subject": {
    "mediaType": "application/vnd.oci.image.manifest.v1+json",
    "artifactType": "application/vnd.agntcy.oasf.record.v1+json",
    "digest": "sha256:7e346bc58473bc1d8a98776fa2a89a3e2a446b27f0e8a33ad49c3d4f28b6471d",
    "size": 702
  }
}
```

## Record CID

The Content Identifier (CID) for a Record Artifact provides an immutable, globally unique, content-addressed reference derived from the cryptographic digest of the OCI image manifest. 

The Record CID is computed using the [CIDv1 specification](https://github.com/multiformats/cid) with the following algorithm:

1. **Compute Manifest Digest**: Calculate the SHA-256 digest of the canonical OCI image manifest JSON bytes. This can be performed locally before pushing or retrieved from the OCI registry after artifact publication.

2. **Construct CID**: Encode the digest using CIDv1 format with these components:
   - **Version**: `0x01`
   - **Multicodec**: `0x01`
   - **Multihash**: SHA-256 digest of the manifest, encoded as a [multihash](https://github.com/multiformats/multihash) with:
     - Hash function identifier: `0x12` (SHA-256)
     - Digest length: `0x20` (32 bytes)
     - Digest bytes: The 32-byte SHA-256 hash output

3. **Encode CID**: The resulting binary CID is encoded using base32 for human-readable representation.

Registries that support tagging MAY use CID tags to reference and retrieve specific Record Artifacts efficiently.

## Application Integration

### Open Agent Schema Framework (OASF)

The [Open Agent Schema Framework](https://github.com/agntcy/oasf) (OASF) complements Record Artifact Specification by defining the actual data models for agent-related information referenced in the OCI artifacts.

### Agent Directory Service (ADS)

The [Agent Directory Service](https://github.com/agntcy/dir) (ADS) utilizes Record Artifact Specification to provide secure publication, exchange, and discovery of information about records over a distributed peer-to-peer network.
Services within ADS leverage OCI standards to create links between Record Artifacts and their own OCI artifacts to implement specific functionalities.
For example, ADS Security Service uses [sigstore](https://github.com/sigstore) to sign and verify records by creating a signature OCI artifact linked to the Record Artifact.
This provides security guarantees such as provenance and integrity for records distributed via ADS.

### Third-Party Applications

Third-party applications can build on top of the Record Artifact Specification to create tools and services for managing, distributing, and utilizing agent records.
This can be accomplished by leveraging existing OCI ecosystem components such as registries, clients, and tooling, or by developing custom solutions that link to Record Artifacts via CIDs.

### Runtime Environments

Runtime environments that deploy and manage agents can leverage Record Artifacts to obtain the necessary information for launching and managing agent instances based on the definitions contained within the artifacts.
Implementations can provide management of process lifecycles, monitoring, and other features based on the metadata defined in the records, or by linking records with runtime-specific artifacts.

For example, a local runtime environment can spawn a process for an agent by retrieving its Record Artifact from an OCI registry using its CID `my-agent-cid` and manage its runtime information as part of a `/runtime/my-agent-cid/` directory.

## Security Considerations

When distributing AGNTCY OASF Records as OCI artifacts, it is essential to consider security aspects such as:
- **Integrity**: Ensure the integrity of the OCI artifacts by verifying the digest of the image manifest and layers upon retrieval.
- **Confidentiality**: If records contain sensitive information, consider encrypting layers or using secure transport mechanisms (e.g., TLS) when transferring artifacts.
- **Provenance**: Maintain metadata about the origin and history of the records to ensure trustworthiness and traceability.
