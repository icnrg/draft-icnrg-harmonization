# Background

<!-- **TODO**: Brief history of CCN, and design and development of CCNx before and during NDN project. -->

## CCNx 0.x: Origin and Point of Commonality

A note of notation first: the CCNx 0.x documents use the word “message" to refer to packet.  CCNx 1.0 gives distinctive and different definitions to “messsage" and “packet".  To avoid confusion, the following uses the word packet in CCNx 0.x description.

### Packet Format

<!-- CCNb (binary-encoded XML) encoding -->

CCNx 0.x defines a variable-length encoding format using binary XML encoding (ccnb).  This encoding defines all packet formats by XML schemas with explicitly identified field boundaries.  This protocol format design permits field values of arbitrary length, nested structures, and optional fields that consume no packet space when omitted.

### Name

CCNx 0.x defines a hierarchical naming structure, each component in a name can be an arbitrary length sequence of zero or more bytes.
Encoding of the name follows the overall packet format, i.e., represented on wire as binary-encoded XML.

In addition to an explicitly defined sequence of name components, the name of each Data packet includes an additional implicitly appended name component: the implicit digest.
This component contains the raw bytes of the SHA-256 digest of the entire ccnb-encoded Data.

CCNx 0.x also defines a set of naming conventions on how to encode various information as part of the name, including binary data, versions, segments, meta-data header, and commands.

<!-- file:///Users/cawka/Downloads/ccnx/doc/technical/NameConventions.html -->

### Packet Types

CCNx 0.x defines two packet types: Interest and Data (also called Content Object).

An **Interest** packet is used to request data by name. The name can be either
a prefix, an exact, or a full name of the desired data to be retrieved; if the name is a prefix, the Interest may carry optional "selectors" to restrict which content is preferred when multiple pieces of them all fall under the given prefix.

The name is defined as the only required element in an Interest packet; other optional elements that an Interest may carry can be sorted into the following categories:

- a means for detecting duplicate Interest: `Nonce`;
- limiters on the Interest: `Scope`, `InterestLifetime`;
- limiters on the answer: `AnswerOriginKind`, `MinSuffixComponents`, `MaxSuffixComponents`, `PublisherPublicKeyDigest`, and `Exclude`;
- advisers on which piece of the multiple Data packets that all satisfy the name carried in an Interest: `ChildSelector` (leftmost, rightmost).

A **Data** packet is named piece of content that is immutable bound together with a cryptographic signature.
The specific type of the signature is defined as part of the `SignedInfo` field in form of OID identifier.

The structure of a Data packet is defined as `Signature`, `Name`, `SignedInfo`, and `Content`.
The `Signature` fields carries cryptographic digest and public key signature (plus "witness" for special type of Merkle-tree group signature), computed over the rest of the ccnb-encoded part of the packet.
The `SignedInfo` is allows inclusion of:

- `PublisherPublicKeyDigest`: digest of the public key to verify the signature;

- `Timestamp`: specially encoded timestamp value of when packet was created;

- `Type`: three-byte identification of the payload with several defined values, including DATA, ENCR, GONE, KEY/, LINK, and NACK;

- `FreshnessSeconds`: how many seconds a node should wait after the arrival of this ContentObject before marking it as stale;

- `FinalBlockID`: the trailing name component in the last Data packet of a sequence of fragments;

- `KeyLocator`: key bits or name of the public key to verify the signature; and

- `ExtOpt`: carrier for any additional application-defined meta-information.

CCNx 0.x defines a concept of Data packet staleness.
A newly received (or re-retrieved) Data packet is considered "not stale" for the duration limited by `FreshnessSeconds` (always not stale if Data packet does not carry the field).
"Stale" content objects are still valid data, but they are not eligible to be matched with Interests, unless "answer may be stale" bit set in the Interest's `AnswerOriginKind` element.

### Forwarding Behavior

A CCNx 0.8 specification defines the following forwarder behavior for processing of Interest and Data packets:

- Interest Processing

    - Check if Nonce present, insert a random one if missing

    - Check if Nonce has been previously seen, drop Interest if so

    - Lookup for a similar Interest in the Pending Interest Table (PIT)

        - If found, aggregate the newly received Interest, unless PIT is close to expiration; terminate processing

    - Lookup a matching Data in the local Content Store

        - If a match found, return the corresponding Data packet

    - Lookup the Forwarding Information Base (FIB)

        - If no matching FIB entry, drop the Interest and stop processing

        - If found, record the Interest in the PIT state and lookup previously observed data plane performance information (e.g., for the prefix)

        - Forward the Interest using the forwarding strategy mechanism, based on FIB order and (if found) observed data plane performance info:

- Data processing

    - Find all Interests in the PIT that the Data packet satisfies according to the matching rules described above.

    - Forward the Data packet along each of those reverse paths, then remove those PIT entries.

    - If it matched at least one PIT entry, put the Data packet in the Content Store.

CCNx 0.8 codebase uses ["two-best route then flood" strategy](https://redmine.named-data.net/projects/nfd/wiki/CcndStrategy).
Each forwarder for each name prefix in its FIB keeps an estimate of the round-trip time.
If an Interest goes unsatisfied longer than this estimate, the forwarder either looks up the second best FIB entry (if exists) and forwards the Interest there (first timeout) or sends Interests to the remaining FIB entries (if any).
The intention of this approach is to adaptively explore available paths and retrieve Data, taking advantage of CCNx 0.8 design to prevent Interest loops through PIT state and Nonce mechanisms.
<!-- The implemented strategy uses an information foraging approach to estimate  -->
The estimate is initialized to a hard-coded value between 8 and 12 msec and uses multiplicative increase multiplicative decrease approach with constant 1/128 to adjust it after receiving Data (decrease to t = 0.992 * t) or upon timeout (increase to t = 1.125 t).
This means that about every 8th Interest will trigger a timeout and sending on the second best path.
This infrequent use of the second best path updates that path's RTT estimate.

<!-- LZ: the description is too "mechanical"; need to spell out the intension behind the design: a heuristic implementation for resilient forwarding, take advantage of the fact Interest packets should not loop -->

The CCNx 0.x forwarder uses a set of flags on FIB entries called Child Inherit and Forward Capture [cite NFD dev guide?].
By default, the FIB matching takes a strict longest prefix matching approach.  If the Child Inherit flag is set on a shorter prefix, it indicates that shorter prefixes should be considered equally feasible as the longer matching prefixes.  The Forward Capture flag on a shorter prefix indicates that no longer prefix should be used (it avoids another process from "capturing" the FIB entry by making a longer entry).
<!-- LZ: do you mean that it avoids any longer FIB entries from capturing the Interest? -->
The use of these two flags has a strong interaction with the "two-best route then flood" forwarding strategy, as they either expand or contract the set of feasible routes used in Interest forwarding and Interest timeout retransmission.

## Summary of Changes

### Protocol Changes Made by the NDN Team

Based on a common understanding of the inefficiency from ccnb packet encoding used by CCNx 0.8, in 2013 NDN Team created, and subsequently revised, a new [NDN protocol specification](#ndn-spec).
The new version has kept the essential semantics and properties of the original CCNx: flexibility in packet format encoding, support of prefix match between interests and data packet to support in-network name discovery, which is required in supporting data immutability as consumers may not know the exact or full name of the desired data, which may be produced in real time or even in response to the Interest request.

<!-- no fixed header -->

The following list is a brief summary of the changes to CCNx 0.8 made by the NDN specification.

**Semantics**:

- Per-namespace forwarding strategy selection

- to be added
<!-- LZ: what do you have in mind to talk here ? -->
<!-- AA: Forwarding Hints and consideration for matching no more than one data for an interests, though not sure if it semantics -->

**Encoding**:

- The XML binary encoding is replaced by "Type-Length-Value" (TLV) encoding, with `Type` and `Length` encoded using a flexible 1-3-5-8 octet encoding.

**Name**:

- Accordingly the encoding of names is changed to a two-level nested TLV, outer TLV for a name and sub-TLVs for "typed" name components

    - Introduced several generic name component types, including `GenericNameComponent` and `ImplicitSha256Digest`.  The latter to disambiguate the trailing implicit digest component in an interest name.
    <!-- LZ: I want to make the above a sub bullet, but dont know how -->

- As part of ongoing work, NDN team is working on

    * introducing other general-use name component types, such as `Number`, `Timestamp`, and a few others
    <!-- LZ: I had thought we introduced this a few years back -->

    * changes the Interest-Data matching semantics from matching one interest to zero or multiple data packets (data matches all pending interests with name that is prefix of data and selectors are satisfied), to matching zero or the exact interest which retrieved the data packet (through the use of an "Interest Digest" mechanism).  Note that latter preserves prefix match between interests and data
    <!-- LZ: this belongs to Interest/Data packet processing; should not be under name? -->


**Packet Types**

- Added `Network NACK` (as part of NDNLP adaptation layer)
<!-- LZ: so what do we call this?  if this is part of LP, then it is not NDN packet type -->

**Interest Packet**:

- Changed `Nonce` from being optional to required to aid Interest loop detection, in particular to facilitate more liberal use of Interest multicast/broadcast in edge ad hoc environments where network routing may or may not be used.

- `PublisherPublicKeyDigest` is replaced by `PublisherPublicKeyLocator`
<!-- LZ: what is the reason behind this change? -->

- Changed `AnswerOriginKind` from 4bits to a 1-bit `MustBeFresh` selector

- Removed `FaceID`
<!-- LZ: I cannot recall this: what is the reason behind this change? -->

- Changed `InterestLifetime` unit from second to milliseconds

- Removed Bloom Filter from Exclude

- Deleted deprecated `Scope` guider

- Changed default semantics of staleness: by default an interest may retrieve any data packet with a matching name; if `MustBeFresh` selector is enabled, routers must return non-stale matching data.

- Introduced `ForwardingHint` concept to guide interest forwarding when name cannot be used directly.

- As part of ongoing research, NDN team is considering

    * the addition of a `Payload` field, with requirement for applications to ensure name uniqueness for Interests carrying different payload, e.g., by adding hash of the payload

    * the removal of Interest selectors including "MinSuffixComponents", "MaxSuffixComponents", "PublisherPublicKeyDigest",  "ChildSelector" (leftmost, rightmost), and "Exclude".

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
