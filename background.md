# Background

<!-- **TODO**: Brief history of CCN, and design and development of CCNx before and during NDN project. -->

## CCNx 0.x: Origin and Point of Commonality

A note of notation first: the CCNx 0.x documents use the word “message” to refer to packet.  CCNx 1.0 gives distinctive and different definitions to “messsage” and “packet”.  To avoid confusion, the following uses the word packet in CCNx 0.x description.

### Packet Format

<!-- CCNb (binary-encoded XML) encoding -->

CCNx 0.x defines a variable-length encoding format using binary XML encoding (ccnb).  This encoding defines all packet formats by XML schemas with explicitly identified field boundaries.  This protocol format design permits field values of arbitrary length, nested structures, and optional fields that consume no packet space when omitted.

### Name

CCNx 0.x defines a hierarchical naming structure, each component in a name can be an arbitrary length sequence of zero or more bytes.
Encoding of the name follows the overall packet format, i.e., represented on wire as binary-encoded XML.

In addition to an explicitly defined sequence of name components, the name of each Content Object packet includes an additional implicitly appended name component: the implicit digest.
This component contains the raw bytes of the SHA-256 digest of the entire ccnb-encoded Content Object.

### Packet Types

CCNx 0.x defines two packet types: Interest and Data (also called Content Object).

An **Interest** packet is used to request data by name. The name can be either 
a prefix, or the exact or full name of the desired data to be retrieved; if the name is a prefix, the Interest may carry optional "selectors" to restrict which content is preferred when multiple pieces of them all fall under the given prefix.

The name is defined as the only required element in an Interest packet; other optional elements that an Interest may carry can be sorted into the following categories:

- a means for detecting duplicate Interest: `Nonce`;
- limiters on the Interest: `Scope`, `InterestLifetime`;
- limiters on the answer: `AnswerOriginKind`, `MinSuffixComponents`, `MaxSuffixComponents`, `PublisherPublicKeyDigest`, and `Exclude`;
- advisers of what to send when there are multiple ContentObjects that satisfy the name carried in an Interest: `ChildSelector` (leftmost, rightmost).

The **Content Object** is self-contained named and signed piece of payload.
Formally, a Content Object is an immutable binding of a name, a publisher, and a chunk of data.
Every Content Object packet is required to contain a valid signature, type of which defined as part of the `SignedInfo` field in form of OID identifier.

The structure of the Content Object was defined as `Signature`, `Name`, `SignedInfo`, and `Content`.
The `Signature` fields carried cryptographic digest and public key signature (plus "witness" for special type of Merkle-tree group signature), computed over the rest of the ccnb-encoded part of the packet.
The `SignedInfo` allowed to include:

- `PublisherPublicKeyDigest` (digest of the public key to verify the signature),
- `Timestamp` (specially encoded timestamp value of when packet was created),
- `Type` (3-byte identification of the payload with several defined values, including DATA, ENCR, GONE, KEY/, LINK, and NACK),
- `FreshnessSeconds` (how many seconds a node should wait after the arrival of this ContentObject before marking it as stale),
- `FinalBlockID` (the trailing name component in the last Content Object of a sequence of fragments),
- `KeyLocator` (key bits or name of the public key to verify the signature), and
- `ExtOpt` (carrier for any additional application-defined meta-information).

CCNx 0.x also defined a concept of Content Object staleness.
Any newly received (or re-retrieved) Content Object was considered "not stale" for the duration limited by `FreshnessSeconds` (always not stale if Content Object does not carry the field).
"Stale" content objects are still valid data, but they are not eligible to be matched with Interests, unless "answer may be stale" bit (0x4) set in the `AnswerOriginKind` element.

### Forwarding Behavior

A CCNx 0.8 specification defined the following forwarder behavior for processing of Interest and Content Object (Data) packets:

- Interest Processing

    - Check for duplicate Nonce and drop if found
    - Try to aggregate the Interest in the Pending Interest Table (PIT)

        - If aggregated, done

    - Try to satisfy the Interest from the local Content Store (cache).

        - If a match found, as described above, return the corresponding Content Object

    - Lookup in the Forwarding Information Base (FIB)

        - If no match, drop the Interest
        - If forwarded, record PIT state
        - Forward the Interest as per the FIB lookup

- Interest Response Timeout

    - If this is the 1st timeout, lookup the 2nd-best FIB entry and if it exists, forward, otherwise done.
    - If this is the 2nd timeout, lookup all remaining feasible FIB entries and send to all
    - Beyond this time, keep the Interest until Interest Lifetime expires

- Content Object processing

    - Find all Interests in the PIT that the Content Object satisfies according to the matching rules described above.
    - Forward the Content Object along those reverse paths, then remove those PIT entries.
    - If it matched at least one PIT entry, put the Content Object in the Content Store

The Interest processing path in a forwarder follows a two-best route then flood strategy.  Each forwarder for each name prefix in its FIB keeps an estimate of the round-trip time.  If an Interest goes unsatisfied longer than this estimate, it follows the Interest Response Timeout processing path.  The CCNx 0.x forwarder uses a kind of information foraging approach.  It will steadily decrease the RTT estimate used on the best path until an Interest goes unsatisfied then reset to the true estimate.  This means about every 8th Interest will trigger a send on the 2nd best path.  This infrequent use of the 2nd best path updates that path's RTT estimate.  If neither the best path nor second best path yields a response, the forwarder will broadcast the Interest any remaining feasible FIB entries.

The CCNx 0.x forwarder uses a set of flags on FIB entries called Child Inherit and Forward Capture.  Normally, the FIB is matched on a strict longest matching prefix.  If the Child Inherit flag is set on a shorter prefix, it indicates that shorter prefixes should be considered feasible in addition to longer prefixes.  The Forward Capture flag on a shorter prefix indicates that no longer prefix should be used (it avoids another process from "capturing" the FIB entry by making a longer entry).  The use of these two flags has a strong interaction with the two-best route then flood forwarding strategy as they either expand or contract the set of feasible routes used in Interest forwarding and Interest timeout retransmission.

## Summary of Changes

### NDN Changes

Based on the common understanding of inefficiency of ccnb packet encoding of CCNx 0.8, in 2013 NDN Team has created, and subsequently revised, the new [NDN protocol specification](#ndn-spec).
At the same time, the new version kept the semantics and properties of the original CCNx: flexibility of the encoding, prefix match between interests and data to support data immutability and in-network name discovery.

<!-- no fixed header -->

The following list is a brief summary of these introduced changes.

**Semantics**:

- to be added

**Encoding**:

- The XML binary encoding replaced with "Type-Length-Value" (TLV) encoding, with `Type` and `Length` encoded using a flexible 1-3-5-8 octet encoding.

**Name**:

- Name changed to be a two-level nested TLV, outer TLV and "typed" name components sub-TLVs

- Introduced several generic name component types, including `GenericNameComponent` and `ImplicitSha256Digest`.
  The latter to disambiguate the trailing implicit digest component of the interest name.

- As part of ongoing work, NDN team

    * introducing other general-use name component types, such as `Number`, `Timestamp`, and a few others

    * changes semantics to match one interest to zero or many data packets (data matches all pending interests with name that is prefix of data and selectors are satisfied) to zero or one match (data matches the exact interest it was retrieved by using "Interest Digest" mechanism).  Note that latter preserves prefix match between interests and data

    * considers removal of `Exclude` and other selectors.

**Packet Types**

- Added `Network NACK` (as part of NDNLP adaptation layer)

**Interest Packet**:

- `Nonce` is changed from optional to required to ensure that loops can be quickly detected and pruned, relaxing requirement for the routing system and critical in ad hoc environments.

- `PublisherPublicKeyDigest` is replaced by `PublisherPublicKeyLocator`

- `AnswerOriginKind` is simplified from 4bits to a 1-bit `MustBeFresh` selector

- `FaceID` has been removed

- `InterestLifetime` changes the unit to the number of milliseconds

- Removed Bloom Filter from Exclude

- Delete deprecated `Scope` guider

- Changed default semantics of staleness: interest without selectors bring any matching data; if `MustBeFresh` selector is enabled, routers must return only "fresh" matching data.

- Introduced `ForwardingHint` concept to guide interest forwarding when name cannot be used directly.

- As part of ongoing discussion, NDN team considering adding

    * `Payload` field, with requirement for applications to ensure name uniqueness for Interests carrying different payload, e.g., by adding hash of the payload

**Data Packet**:

- The structure of Data packet is changed to `Name`, `MetaInfo`, `Content`, `Signature{SignatureInfo, SignatureValue}`
- `PublisherPublicKeyDigest` and `ExtOpt` are removed.
- `SignedInfo` is renamed to `MetaInfo` and its content was refactored:

    * Three content types, ENCR, GONE, and NACK are removed
    * `Timestamp` is removed
    * `KeyLocator` is moved to be inside the `Signature` (`SignatureInfo`) block
    * `FreshnessSeconds` is renamed to `FreshnessPeriod` and is expressed in units of milliseconds
    * `MetaInfo` now allowed to contain application-specific blocks, e.g., to carry timestamp of data production.
    * `Timestamp` removed

- As part of ongoing discussion, NDN team considering adding

    * an additional field outside security envelope to record time the Data packet spend in in-network caches (to streamline freshness/stale in-network storage semantics)

**Signature**:

  - `Signature` is moved to the end of Data packet.
  - `KeyLocator` is moved to be a part of the `SignatureInfo` block and made signature-specific.
  - Signature type (or signing method information) is expressed as an assigned integer value (with no assumed default), rather than OID.
  - Added support for hash-only "signature"
  - Introduction support of new types of signatures, including `SignatureSha256WithEcdsa` (Elliptic Curve Digital Signature Algorithm) and `SignatureHmacWithSha256` (hash-based packet authentication code)
  - `KeyLocatorDigest` renamed to `KeyDigest`

### CCNx 1.0 Changes

In the beginning of 2013, PARC team has undertaken a significant revision of CCNx (CCNx 1.0), refactoring the protocol behavior and packet format.

<!-- to allow optimization of forwarding behavior. -->
<!-- In more details, the changes are described in the next section, -->
The following list is a high-level summary of the changes.

**Semantics**

- The semantics of data retrieval got constrained to retrieval by "exact" or "full" names only.
The advantage of this change is significant simplification of the forwarding process, allowing various hardware and software optimization techniques (?cite?).
At the same time, the communication using the constrained semantics requires additional mechanism and semantics changes.
The full (and some exact) names must be explicitly communicated to the consumers by an out-of-band (e.g., an application-level name discovery, such as manifests and directory service) mechanisms.
To bootstrap these mechanism required changes of "immutable data" semantics: the same name need to be associated with different content at different times with time-dependency on the network routers to removing "old" versions from the network.

- Interest aggregation

- Data packet semantics changed from fresh/stale to alive/dead: added a requirement on in-network caches to stop serving data for interests after producer-defined time ("time-dependent" immutability)

**Encoding**:

- The XML binary encoding replaced with "Type-Length-Value" (TLV) encoding, with `Type` and `Length` encoded using a fixed 2-octet encoding.
A separate specialized IoT version (requires translation) of CCNx 1.0 (?cite?) added a 1-octet encoding of combined T-V fields.

**Name**:

- Name changed to be a two-level nested TLV, outer TLV and "typed" name components sub-TLVs

- Introduced free-to-define name component types

- Implicit digest changed from being a part of the name (implicitly added name component, ensuring uniqueness of the full name) to be an independent identifier that can be used as part of "hash restriction".

**Packet Types**

- Added `InterestReturn` packet

**Interest Packet**

- Introduced a "fixed" common header, with optional TLV-encoded hop-by-hop headers (not covered by signature), followed by TLV-encoded Interest packet.

- Introduced "HopLimit" (as part of fixed header)

- `Nonce` removed (killing loops via HopLimit, no detection of loops)

- `MinSuffixComponents`, `MaxSuffixComponents`, `Exclude`, and `ChildSelector` selectors removed (as a consequence of the data retrieval semantics change)

- `AnswerOriginKind` selector removed, as a consequence of data packet semantics change

- `PublisherPublicKeyDigest` selector replaced with KeyId restriction

- `Scope` removed (replaced with HopLimit)

- `FaceID` removed

- Added optional `Payload` field

**Data Packet**

- Introduced a "fixed" common header, with optional TLV-encoded hop-by-hop headers (not covered by signature), followed by TLV-encoded Interest packet.

- Introduced concept of "nameless" objects, which are identified only by their implicit digest

- Added timestamp after which packet cannot satisfy interests

- `FinalBlockID` ?

**Signature**:

- to be added
