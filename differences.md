# Discussion of Individual Architecture & Design Commonalities and Differences per NDN and CCNx 1.0 Development paths

... below we take in succession individual topics that capture the points where the differences between the NDN and CCNx 1.0 approaches are relevant and important to discuss.  The topics listed below are taken from our prior discussions and are included for completeness only. We can reorganize, add or delete items as we see fit. The structure of each section will be the same as suggested in 4.1...

<!-- ################################################################### -->

## Packet encoding

Use of TLV encodings

### NDN

.. Details and motivation...

### 	CCNx 1.0

CCNx 1.0 uses a TLV packet format.  It allocates 2 bytes for the Type and 2 bytes for the Length (called the "2+2 format").  There are two principle reasons for using a fixed T and L length.  First, it avoids aliases.  For example is a 1-byte "0" the same as a 2-byte "0"?  If so, it means there are multiple representations of the same semantics, so creating packet filters becomes much harder.  If they are not the same, then a parser needs to differentiate them based on length.   The second reason is packet allocation.  Because the length of a L depends on how much is inside it, which might not be known at first, one sometimes needs to reserve space for an L field then come back to fill it in later.  We also believe that a fixed T and L length leads to a much more efficient parser because it does not need to branch on each T and L field.

The 2+2 format is inefficient bit-wise because many fields are under 255 bytes and we use maybe a dozen types, not thousands of types.  To address this, we have proposed two additional protocols, though these are not part of the standard.  The first is a compression protocol that is more efficient than even a protocol that can use 1 or 2 byte T and L fields (https://www.ietf.org/proceedings/94/slides/slides-94-icnrg-0.pdf).  One reason for this is that in a series of Content Objects, it can compress out other repeated fields, such as parts of the name, long cryptographic key digests, and repeated TLV blocks like the Validation Algorithms section.  The second is an encoding for 802.15.4 (or other small data environments) called the "1+0" TLV format because it uses only 1 byte for both the T and the L in many cases (see https://www.ietf.org/mail-archive/web/icnrg/current/pdfs9ieLPWcJI.pdf).

### Analysis


<!-- ################################################################### -->

## Packet structure

General: There are three layers for ICN with semantic differences

- ICN information layer
- Network adaptation layer; different network types may have different network adaptation layer formats
- Link adaptation layer (“link” also includes tunnels) may be different for different link types

### NDN

... Details and motivation ...

### CCNx 1.0

A packet contains four sections:

- Fixed header: A fixed length header that specifies a forwarder behavior (PacketType), the total packet length,
the header length, and has a small amount of space for per-PacketType fields.
- Per-hop headers: A list of TLVs that are outside the signature envelope and are thus mutable.  These are used for network layer adaptation (see next item) or fields that need to change in flight, such as a remaining lifetime field.
- CCNx message: A TLV container for a Content Object or an Interest or an Interest Return.
- Validation: This is two TLV blocks, one that contains information about the validation, such as keyid and signing parameters like the crypto suite, and another that has the actual signature.  The signature covers the CCNx message and the first block of the validation section.

CCNx 1.0 uses the same packet envelope for all CCNx messages.


**Uses of HopLimit**

An option to scope interest forwarding using HopLimit field.  CCNx 1.0 informally maintains the CCNx 0.x conventions of /localhost, but that convention is not in the standard.

CCNx 1.0 has not adopted a /localhop convention because it can be achieved via the HopLimit.  We also believe that each link should be uniquely named to avoid confusion in the FIB and ContentStore.  Clearly, /localhop prefixed names cannot use FIB forwarding and they cannot be stored in a common ContentStore.


<!-- Bundled ICN information and network adaptation layer into the same packet header -->
<!-- Not yet defined link adaptation layer, except fragmentation handling -->
<!-- (see -->

https://tools.ietf.org/html/draft-mosko-icnrg-ccnxfragmentation-01


### Analysis

<!-- ################################################################### -->

<!-- ## Interest Payloads -->

 <!-- (network adaptation, link adaptation, information layers) -->


<!-- ################################################################### -->

## Naming

NDN and CCNx 1.0 has the same definitions of naming and extended it

+ Explicitly typed components

// definition of Data digest

In CCNx 1.0, full name combines of "Name" and "digest" but is not logically tied together

### NDN

Talk about: Name based scoping using a set of naming conventions, including "/localhost" and "/localhop"


<!-- ################################################################### -->

## Data retrieval

### NDN

Data can be retrieved by full, exact, and prefix name.
NDN includes an assumption that exact names are not intentionally reused by different data

<!-- ## In-network name discovery -->
<!-- ### NDN -->

Selector support

- As a temporary mechanism to implement in-network name discovery
- Open research for the adequate replacement

"FreshnessPeriod" in Data packets as a relative time to treat Data "fresh" for discovery purposes

**Similar Interest Aggregation**

<!-- ### NDN -->

Exponential-back off interval to allow interest retransmission


### CCNx 1.0

Data can be retrieved only using full or exact name.

<!-- ### CCNx 1.0 -->

App-defined name discovery:

- Manifests for static data
- Encoding Selectors as part of the Interest name


**Similar Interest Aggregation**

CCNx 1.0 recommends this interest aggregation algorithm:

- Two Interests are considered 'similar' if they have the same Name,
      KeyIdRestr, and ObjHashRestr.
- Let the notional value InterestExpiry (a local value at the
      forwarder) be equal to the receive time plus the InterestLifetime
      (or a platform-dependent default value if not present).
- An Interest record (PIT entry) is considered invalid if its
      InterestExpiry time is in the past.
- The first reception of an Interest must be forwarded, within 
      the ability of the system.
- A second or later reception of an Interest similar to a valid
      pending Interest from the same previous hop MUST be forwarded.  We
      consider these a retransmission requests.
- A second or later reception of an Interest similar to a valid
      pending Interest from a new previous hop MAY be aggregated (not
      forwarded).
- Aggregating an Interest MUST extend the InterestExpiry time of the
      Interest record.  An implementation MAY keep a single
      InterestExpiry time for all previous hops or MAY keep the
      InterestExpiry time per previous hop.  In the first case, the
      forwarder might send a ContentObject down a path that is no longer
      waiting for it, in which case the previous hop (next hop of the
      Content Object) would drop it.


<!-- ################################################################### -->

## Opportunistic in-network caching

Both protocols include ability to cache each forwarded data packet with forwarded-defined policies

### NDN

"Fresh"/"stale" semantics for the cached data
(CS can keep stale packet and satisfy Interests that do not request "fresh" data)

### CCNx 1.0

alive/dead semantics: Requirement that CS cannot use "dead" data to satisfy interests
(current spec only) CS alive/dead decision requires absolute time synchronization within required discovery resolution
Requirement for Cache verification: if Interest specifies KeyRestriction, cache cannot satisfy the interest without verification

<!-- ################################################################### -->


<!-- ################################################################### -->

## Forwarding Loop Management

### NDN

...NDN assumes networks without guarantees for loopless routing (assumes that routing either don’t exist or have high chance to result in looping paths)...

PIT state to stop the interest from forwarding

"Nonce" to detect potentially duplicated interests with ability to prune "duplicate" paths

"HopLimit" to kill interest loops in special cases

### CCNX 1.0

CCNx 1.0 uses a HopLimit field in the fixed header of Interest packets.  This field restricts an Interest to at most 255 hops, so a loop will eventually terminate.  An Interest loop would likely terminate faster than that because once it completes its first cycle it would either find a Pending Interest Table entry that aggregates it (suppressing forwarding it) or it finds a ContentStore entry that satisfies it.  The vulnerability to longer loops occurs when PIT entries get satisfied faster than the loop period and the Content Object is either not cachable or a node has no cache or its cache entry gets evicted too fast.

CCNx 1.0 also recommends decrementing the Interest Lifetime by an appropriate amount at each hop, which also serves to limit looping.

CCNx 1.0 assumes that routing protcocols produce routes without permanent loops.




<!-- ################################################################### -->

## Data Security

### NDN

- Exploring signature formats: RSA, ECDSA, HMAC
- Command (Signed) Interests
- Trust schema
- Name based access control

### CCNx 1.0
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

## Indirect data retrieval

### NDN

LINK object

### CCNx 1.0

Special handling of Data packets that do not include "Name" field (=retrieved using data digest)

Data is matched against "restriction" field; name is completely ignored

<!-- ################################################################### -->

<!-- ## 	Sync -->

<!-- ### NDN -->

<!-- ChronoSync, RepoSync, ChronoSync 2.0, PartialSync "refs" -->

<!-- ### CCNx 1.0 -->

<!-- Manifest-based synchronization "refs" -->
