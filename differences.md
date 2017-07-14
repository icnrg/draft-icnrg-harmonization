# Discussion of Individual Architecture & Design Commonalities and Differences per NDN and CCNx 1.0 Development paths

<!-- ... below we take in succession individual topics that capture the points where the differences between the NDN and CCNx 1.0 approaches are relevant and important to discuss.  The topics listed below are taken from our prior discussions and are included for completeness only. We can reorganize, add or delete items as we see fit. The structure of each section will be the same as suggested in 4.1... -->

<!-- ################################################################### -->

<!-- ################################################################### -->

## Packet Structure

In general, ICN packets require for the following three components (some optional) with semantic differences:

- (required) ICN information layer (message).

    This layer need to include elements that are necessary to describe requests for the data and to describe and secure the data, such as data name, data name constraints, payload, security context, security context constraint, etc.

- (optional) Network adaptation layer

    This layer define elements that needed to assist information-layer packet forwarding in a specific network environment (across multiple hops).
    Examples of such elements could include ...

- (optional) Link adaptation layer

    This layer defines mechanisms to deliver messages with optional network adaptation elements across specific links.
    For example, for small-MTU links, link adaptation can define fragmentation elements (cite?); for lossy links, hop-by-hop recovery mechansms (cite?), etc.

**NDN**

The NDN packet specification defines information-layer packets, including some of the elements that potentially belong to the network adaptation layer.  There is an ongoing discussion to reorganizing the defined packet format to clearly separate information- and network adaptation layer elements.

A set of companion specifications (NDNLP [cite?], lora [cite?]) defined link adaptation elements, including hop-by-hop fragmentation, packet recovery, congestion information gathering, geo-tags, etc.

... some elements in NDNLP potentially belong to different layers and NDN Team is considering restructuring ...

**CCNx 1.0**

CCNx 1.0 specification defines a single packet structure consisting of four section, incorporating elements of ICN information, network adaption, and link adaptation layers:

- Fixed header

    A fixed length header that specifies a forwarder behavior (PacketType), the total packet length,
    the header length, and has a small amount of space for per-PacketType fields.

- Per-hop headers

    A list of TLVs that are outside the signature envelope and are thus mutable.  These are used for network layer adaptation (see next item) or fields that need to change in flight, such as a remaining lifetime field.

- Message

    A TLV container for a Content Object or an Interest or an Interest Return.

- Validation

    This is two TLV blocks, one that contains information about the validation, such as keyid and signing parameters like the crypto suite, and another that has the actual signature.  The signature covers the CCNx message and the first block of the validation section.


<!-- ### Analysis -->

<!-- ################################################################### -->

<!-- ## Interest Payloads -->

 <!-- (network adaptation, link adaptation, information layers) -->


<!-- ################################################################### -->

## Packet Encoding

**NDN**

NDN packet is encoded as a pure TLV encoding using a flexible 1-3-5-9-octet format for `Type` and `Length` fields.
<!-- Data and Interest packets are complete and self-contained TLV blocks. -->

Advantages:

- The objective of the flexible encoding format is to ensure the same packet format can be used in all possible network environments, including very constrained IoT and high-performance unconstrained networks, without requiring translation gateways.

Potential drawbacks:

- More complex processing (direct interpretation of wire-format bytes)

- More complex packet generation (optimal implementation of packet allocation require packet size estimation and backward-direction encoding)

- Number aliasing, if implementations do not enforce the smallest-encoding restriction imposed by the NDN's TLV specification.

**CCNx 1.0**

As highlighted above, different parts of the CCNx 1.0 packet use different type of encoding:

- the common fixed header is defined as 8 octets that can be followed by one or more hop-by-hop headers.
  The dedicated header length field determines the hop-by-hop header space in the "fixed" header.

- hop-by-hop headers, message, and validation fields are encoded using TLV encoding with a fixed 2-octet encoding for `Type` and `Length` fields.

Advantages:

- No number aliasing possible, as the encoding is fixed

- Simplified processing

- Simplified packet generation (still require packet size estimation, but allow both forward and backward encoding)

Potential drawbacks:

- Can encode numbers only up to 65,535, which can be limiting factor for L field in high-performance networks and for T field when assigning custom fields.

- Inefficient bit-wise because many fields are under 255 bytes

- Need for [specialized encoding](https://www.ietf.org/mail-archive/web/icnrg/current/pdfs9ieLPWcJI.pdf) and/or [compression mechanisms](https://www.ietf.org/proceedings/94/slides/slides-94-icnrg-0.pdf) to use in highly MTU-constrained networks (802.15.4, LoRaWAN, etc.)



## Naming

The naming structure of NDN and CCNx 1.0 is almost equivalent, as both define name as a set of typed name components.
The only difference is interpretation of the name in relation to the data packet:

- Name of NDN data packet implicitly includes the digest as a last component.  This makes data name to have at least one (ImplicitSha256Digest) component when producer set `ndn:/` as the data packet's name (`Name` field is required in both Interest and Data packet)

- CCNx 1.0 does not include the digest as a last component, but allows the data packet digest to be used as the sole identifier of the data packet, as part of "hash restriction".
  In addition to that, CCNx 1.0 makes `Name` an optional field in data packet, differentiating packet with `ccnx:/` name and packet with omitted `Name` field (so called nameless objects).




<!-- ################################################################### -->

## Data Retrieval


**NDN**

Data can be retrieved by full, exact, and prefix name.
NDN includes an assumption that exact names are not intentionally reused by different data

<!-- ## In-network name discovery -->
<!-- ### NDN -->

Selector support

- As a temporary mechanism to implement in-network name discovery
- Open research for the adequate replacement

"FreshnessPeriod" in Data packets as a relative time to treat Data "fresh" for discovery purposes

**NDN**

Talk about: Name based scoping using a set of naming conventions, including "/localhost" and "/localhop"


**Similar Interest Aggregation**

<!-- ### NDN -->

Exponential-back off interval to allow interest retransmission


**CCNx 1.0**

Data can be retrieved only using full or exact name.

<!-- ### CCNx 1.0 -->

App-defined name discovery:

- Manifests for static data
- Encoding Selectors as part of the Interest name


**Similar Interest Aggregation**

CCNx 1.0 recommends this interest aggregation algorithm:

- Two Interests are considered "similar" if they have the same `Name`, `KeyIdRestr`, and `ObjHashRestr`.

- Let the notional value InterestExpiry (a local value at the forwarder) be equal to the receive time plus the InterestLifetime (or a platform-dependent default value if not present).

- An Interest record (PIT entry) is considered invalid if its InterestExpiry time is in the past.

- The first reception of an Interest must be forwarded, within the ability of the system.

- A second or later reception of an Interest similar to a valid pending Interest from the same previous hop MUST be forwarded.  We consider these a retransmission requests.

- A second or later reception of an Interest similar to a valid pending Interest from a new previous hop MAY be aggregated (not forwarded).

- Aggregating an Interest MUST extend the InterestExpiry time of the Interest record.  An implementation MAY keep a single InterestExpiry time for all previous hops or MAY keep the InterestExpiry time per previous hop.  In the first case, the forwarder might send a ContentObject down a path that is no longer waiting for it, in which case the previous hop (next hop of the Content Object) would drop it.


<!-- ################################################################### -->

## Opportunistic In-Network Caching

Both protocols include ability to cache each forwarded data packet with forwarded-defined policies

**NDN**

"Fresh"/"stale" semantics for the cached data
(CS can keep stale packet and satisfy Interests that do not request "fresh" data)

**CCNx 1.0**

alive/dead semantics: Requirement that CS cannot use "dead" data to satisfy interests
(current spec only) CS alive/dead decision requires absolute time synchronization within required discovery resolution
Requirement for Cache verification: if Interest specifies KeyRestriction, cache cannot satisfy the interest without verification

<!-- ################################################################### -->


<!-- ################################################################### -->

## Forwarding Loop Management

**NDN**

...NDN assumes networks without guarantees for loopless routing (assumes that routing either don’t exist or have high chance to result in looping paths)...

PIT state to stop the interest from forwarding

"Nonce" to detect potentially duplicated interests with ability to prune "duplicate" paths

"HopLimit" to kill interest loops in special cases

**CCNx 1.0**

CCNx 1.0 uses a HopLimit field in the fixed header of Interest packets.  This field restricts an Interest to at most 255 hops, so a loop will eventually terminate.  An Interest loop would likely terminate faster than that because once it completes its first cycle it would either find a Pending Interest Table entry that aggregates it (suppressing forwarding it) or it finds a ContentStore entry that satisfies it.  The vulnerability to longer loops occurs when PIT entries get satisfied faster than the loop period and the Content Object is either not cachable or a node has no cache or its cache entry gets evicted too fast.

CCNx 1.0 also recommends decrementing the Interest Lifetime by an appropriate amount at each hop, which also serves to limit looping.

CCNx 1.0 assumes that routing protcocols produce routes without permanent loops.


**Uses of HopLimit**

An option to scope interest forwarding using HopLimit field.  CCNx 1.0 informally maintains the CCNx 0.x conventions of /localhost, but that convention is not in the standard.

CCNx 1.0 has not adopted a /localhop convention because it can be achieved via the HopLimit.  We also believe that each link should be uniquely named to avoid confusion in the FIB and ContentStore.  Clearly, /localhop prefixed names cannot use FIB forwarding and they cannot be stored in a common ContentStore.


<!-- Bundled ICN information and network adaptation layer into the same packet header -->
<!-- Not yet defined link adaptation layer, except fragmentation handling -->
<!-- (see -->

https://tools.ietf.org/html/draft-mosko-icnrg-ccnxfragmentation-01


<!-- ################################################################### -->

## Data-Centric Security

**NDN**

- Exploring signature formats: RSA, ECDSA, HMAC
- Command (Signed) Interests
- Trust schema
- Name based access control

**CCNx 1.0**

There is one packet envelope with optional Validation on both Interest and Content
Validation can be a MIC, MAC, or Signature.  We allow formats like a CRC, an HMAC, Elliptical Curve, and RSA.  We also allow unsigned packets, which are used when trust is achieved via hash chains from a previously signed packet.

Validation only covers the Message and the ValidationAlg, not the optional headers or fixed header.

CCNx 1.0 allows signing Interests.  This is usually to allow a CRC on Interest to protect against in-network corruption.  However, the Interest may be signed via a stronger signature within an application usage.  CCNx does not recommend signing or processing signed Interest when the application protocol is not expecting such, as this is a computational denial of service vector.

The CCNx KeyExchange (CCNxKE) protocol (see https://tools.ietf.org/html/draft-wood-icnrg-ccnxkeyexchange-01) is an on-line key exchange protocol similar to TLS 1.3 to negotiate encryption keys.  We believe this form of session security is intrinsically useful and should be supported within an ICN, even though other forms of off-line publishing encryption may be used in other cases.


<!-- ################################################################### -->

## Fragmentation

Both NDN and CCNx use hop-by-hop fragmentation, though the specific details on
the fragmentation protocol differ.

<!-- ################################################################### -->

## Indirect Data Retrieval

**NDN**

Forwarding Hint

**CCNx 1.0**

Special handling of Data packets that do not include "Name" field (=retrieved using data digest)

Data is matched against "restriction" field; name is completely ignored
