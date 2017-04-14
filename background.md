# Background

**TODO**: Brief history of CCN, and design and development of CCNx before and during NDN project.

<!-- CCNx Release History: -->

<!-- - **0.1.0**: Sep 21, 2009 -->
<!-- - **0.1.1**: Sep 25, 2009 -->
<!-- - **0.1.2**: Nov 3, 2009  -->
<!-- - **0.2.0**: Dec 1, 2009  -->
<!-- - **0.3.0**: Nov 4, 2010  -->
<!-- - **0.4.0**: May 13, 2011 -->
<!-- - **0.4.1**: Sep 14, 2011 -->
<!-- - **0.4.2**: Dec 8, 2011  -->
<!-- - **0.5.0**: Feb 16, 2012 -->
<!-- - **0.5.1**: Mar 9, 2012  -->
<!-- - **0.5.2**: May 8, 2012  -->
<!-- - **0.6.0**: Apr 22, 2012 -->
<!-- - **0.6.1**: Aug 21, 2012 -->
<!-- - **0.6.2**: Oct 2, 2012  -->
<!-- - **0.7.0**: Dec 8, 2012  -->
<!-- - **0.7.1**: Feb 4, 2013  -->
<!-- - **0.7.2**: May 19, 2013 -->
<!-- - **0.8.0**: Aug 12, 2013 -->
<!-- - **0.8.1**: Oct 9, 2013  -->
<!-- - **0.8.2**: Apr 1, 2014  -->

## CCNx 0.x: Origin and Point of Commonality

<!-- CCNx versions 0.1 to 0.8 was a prototype implementation of at the time common CCN/NDN architecture. -->

(Rewrite in progress, to follow this structure)


- Packet format

- Packet types

- Node model

  * Data structures

  * Forwarding behavior)

    - Interest processing

    - Data processing


<!-- CCNx protocol which provides location-independent delivery services for named data packets. -->
<!-- The services include multihop forwarding for end-to-end delivery, flow control, transparent and automatic multicast delivery using buffer storage available in the network, loop-free multipath forwarding, verification of content integrity regardless of delivery path, and carriage of arbitrary application data. Applications run the CCNx protocol over some lower-layer communications service capable of transmitting packets. There are no restrictions on the nature of the lower-layer service: it may be a physical transport or another network or transport protocol. For example, applications will typically run the CCNx protocol on top of UDP to take advantage of existing IP connectivity. Since content is named independent of location in the CCNx protocol, it may also be preserved indefinitely in the network, providing effectively a form of distributed filesystem service. -->

<!-- The CCNx protocol is general, supporting a wide range of network applications. It may be natural to think of stored content applications such as distribution of video or document files, but the CCNx model also supports real-time communication and discovery protocols and is general enough to carry conversations between hosts such as TCP connections. The protocol supports a broad range of applications by leaving the choice of naming conventions to the application. This document specifies the common functions that are independent of the contents of the names and data and the semantics of exchanges. In addition to this document, therefore, a complete specification of the use of the CCNx protocol for a particular application will require additional specification of the naming rules, data formats, and message semantics. Such specifications of application protocols on top of the CCNx protocol (plus possibly API specifications) are called profiles. -->

<!-- The CCNx protocol is designed for end-to-end communication between applications and so it is intended to be integrated into application processing rather than being implemented as a separate layer. -->



<!-- The CCNx 0.8 research prototype produced by PARC embodied a set of network functionality and application functionality that reflects a strong application layer framing approach.  At the network level, a forwarder provides several services: (a) Interest aggregation, (b) Interest forwarding, (c) Content Object forwarding along the Interest reverse path, (d) Content Object caching, (e) routing strategies, and (f) in-network discovery of content via partial Interest name matching.  The application domain has all other functionality, such as reliable delivery, Interest retransmissions, signature verification, encryption, and name discovery techniques. -->

<!-- The CCNx 0.8 network protocol is built around an Interest (requst) message and a Content Object (response) message.  Each Interest will bring back at most one Content Object.  This is true for Interests doing in-network discovery and for Interests doing data fetches.  An in-network discovery Interest expresses a name prefix and some parameters (discussed below) to limit the scope of acceptable response names.  In turn, the first cache (Content Store) or producer along the Interest path that has or can generate a Content Object with satisfactory name responds with that Content Object.  Thus, discovery works one request and response at a time.  In part this is because a requester needs to look at the entire Content Object to determine if it truly satisfies the request based on its attributes and its provenance. -->

<!-- CCNx 0.8 matches a Content Object to an Interest (the Content Object satisfies the Interest) based on several attributes of the Content Object and parameters in the Interest.  There is not a one-to-one correspondence, so several different Content Objects could match the same Interest or the same Content Object could match several Interests; in the latter case, we call the Interests similar.  Because there is not a simple rule to determine if two interests are similar, the CCNx forwarder uses a simplification: two Interests are called similar if all Content Object matching terms are equal.  This was accomplished by using a hash over the wireformat of those matching terms in the Interest. -->

<!-- In CCNx 0.8, a Content Object name is a totally ordered hierarchical namespace.  At the network layer, each name component is a variable length opaque byte string of 0 or more bytes.  Name components use a shortlex comparison: if component A is shorter than component B, then A comes before B, otherwise if they are the same length use a byte-wise lexicographic order.  Two names are sorted based on where the first difference occurs in their name components.  For Names, the ordering is just based on the ordering of the first component where they differ.  If one name is a proper prefix of the other, then it comes first.  This ordering is called the canonical name order. -->

<!-- An Interest name comes in three types, differentiated by their intended purpose.  A 'prefix' name is used in name discovery.  It is not intended to match any specific Content Object, but rather to elicit a response of likely Content Objects.  An 'exact' name in an Interest exactly matches a name in a Content Object.  A 'full' name is not used in discovery: it should specifically identify a single Content Object because it includes the cryptographic hash of the Content Object. -->

<!-- The explicit name in a Content Object has 0 or more name components assigned by the application.  Some of these may be used by routing and some may be used by application-defined protocols, such as versioning or segmentation.  A Content Object name has one terminal implicit name component: the so-called implicit hash.  This is the SHA-256 hash of the Content Object itself (and thus cannot be explicit).  A forwarder, when handling a Content Object, always considers the Content Object to have the implicit name component.  This means that both 'prefix' and 'exact' names do in-network discovery because they are always including at least one extra name component.  For example, if a Content Object has a name `/foo/bar`, then it's full name is `/foo/bar/(hash_value)`.  A prefix name could be `/foo` (matching 0 or more suffix components), the exact name is `/foo/bar` (matching exactly 1 suffix component) and the full name is `/foo/bar/(hash_value)` (matching 0 additional suffix components).  The restrictions on the number of additional suffix components is critical in the type of name and the expected matching (the details in an Interest are below). -->

<!-- CCNx 0.8 used some naming conventions that extended the prior description.  For example, a metadata Content Object described another Content Object.  It's naming convention is `/foo/bar/(version)/META/(version)/(segment)/(hash_value)`.  The name `/foo/bar/5/META/3/0/(hash_value)`, for example, identifies a metadata Content Object of version 3 and segment 0 that describes another Content Object names `/foo/bar` with version 5. -->

<!-- Because names are totally ordered, one can exploit this in a name discovery protocol.  A consumer application may emit an Interest whose name is a prefix of one or more Content Objects stored at a forwarded (or peer application).  The discovery protocol allows the consumer to walk the name tree rooted at the Interest prefix.  The consumer can ask for left-most-child or right-most-child and it can also specify Exclusions that move a notional cursor through the sub-namespace.  In addition to range exclusion, an Interest may exclude individual Content Objects.  Based on the name prefix, the child direction preference, and the exclusions, a forwarder (or peer application) responds with the first Content Object in the canonical name order.  One issue that was never handled well in the implementation is when there are two Content Objects that differ only in hash, but not in name.  While it is possible to navigate this situation (see example below), it requires multiple Interest packets and some of the protocol libraries never satisfactorily addressed the possibility. -->

<!-- The common naming convention in CCNx 0.8 is a prefix, such as `/a/b/c`, followed by a version, followed by a segment number, followed by the implicit hash value: `/a/b/c/version/segment/(hash_value)`.  The version is usually a timestamp in network byte order using the minimum number of bytes for the number, but it may be any field that sorts as per canonical order.  The segment is used to fragment a large piece of application data into several Content Objects.  It is usually a sequential number beginning at 0.  The version and segment number are indicated in the name by assuming other name components conform to UTF-8, so the version and segment number use a 'name marker' whose first byte is an invalid UTF-8 code.  In CCNx 0.8, there is an ambiguity between these name markers and binary name components that are not UTF-8 and happen to begin with the same byte sequence. -->

<!-- Up to this point, we have not been including the command marker identifiers in our example names.  Versions, for example, use "`%FD`", segments use "`%00`."  Another special class of markers are the namespace markers.  These indicate that the remaining bytes in the name component introduce a new namespace, such as for metadata (`%C1.META`) or repository commands (`%C1.R`).  There is also a namespace for machine-readable name components, such as keyids (`%C1.M.K%00(key id value)`).  In the remainder of this section, we will continue to abbreviate names and not include the command markers.  A complete reference on command markers is available at https://github.com/ProjectCCNx/ccnx/blob/master/doc/technical/NameConventions.txt. -->

<!-- A CCNx 0.8 Interest is defined as `Interest ::= Name, MinSuffixComponents?, MaxSuffixComponents?, PublisherPublicKeyDigest?, Exclude?, ChildSelector?, AnswerOriginKind?, Scope?, InterestLifetime?, Nonce?, FaceID?`.  We discuss these parameters in the following.  The set of fields that determine if two interests are similar are (*Name*, *MinSuffixComponents*, *MaxSuffixComponents*, *PublisherPublicKeyDigest*, *Exclude*). -->

<!-- ### Interest name matching -->

<!-- An Interest has 'selectors' that determine how a Content Object name matches the Interest name prefix.  The selectors are: (*MinSuffixComponents*, *MaxSuffixComponents*, *Exclude*, *ChildSelector*).  These are all optional. If none are given in an Interest, the Interest will match any suffix of the Interest's name prefix (including 0 suffix components). -->

<!-- MinSuffixComponents specifies the minimum additional suffix components necessary to match and MaxSuffixComponents is similarly the maximum allowed.  An exact name would specify (1,1), that is it need the implicit hash and only the implicit hash.  A full name, which already has the implicit hash, would specify (0,0).  A typical type of discovery is Get Latest Version, where a name is understood to be of the form `/a/b/c/version/segment/(hash_value)`.  An application emits an Interest with prefix `/a/b/c` with (3, 3) for the suffix components and asks for the right-most-child.  This says that the application knows that `/a/b/c` is the specific prefix it wants, and it only needs to discover the latest (right-most) version name component. -->

<!-- The ChildSelector works as we have illustrated it above.  An Interest name, as limited by MinSuffixComponents and MaxSuffixComponents, will induce a totally ordered subset of names rooted at the Interest name.  They are totally ordered because they include the implicit hash terminal component and we will assume there are no collisions.  The ChildSelector defaults to left-most-child (the first of the set).  If one is only interested in the largest name, one can specify the right-most-child. -->

<!-- The Exclude term filters out results from the totally ordered subset of names rooted at the Interest name.  It can include 0 or more range restrictions and 0 or more singleton restrictions.  In typical use in discovery it is a single range restrictions to keep walking through the subset.  Another common usage is to exclude specific implicit hash name components because they are not the desired result (e.g. the signature is invalid).  The exclude filter only applies to the next name component after the Interest prefix.  For example, if the Interest name is `/a/b/c`, then the Exclude will only apply to the name component after `/c`.  Thus, if one wants to Get Latest Version, the Interest name is `/a/b/c` and the Exclude range would apply to the version component of a name like `/a/b/c/version/segment/(hash_value)`. -->

<!-- There are several subtleties to walking the name space via exclusions.  One must not assume there is only one Content Object with a given exact name.  For example, due to an error or design, a given publisher might publish two Content Objects with the same exact name, or due to malice, an attacker could forge a name.  Because the Exclude component only applies to the next name component, when one performs a Get Latest Version, one needs at least two different Interests.  The first walks the name space `/a/b/c` with a range Exclude and the second checks for duplicate Content Objects that differ only in hash, for example `/a/b/c/5/100`. -->

<!-- At this point, it is useful to walk through an example of name discovery.  We will use the Get Latest Version query, as that is a very common usage.  In this example, we use a simple approach and an actual implementation may use more sophisticated algorithms to minimize the number of Interest messages.  Let's assume we have an application and it knows it wants to retrieve the latest version of `/parc.com/index.html`.  It knows the full name will follow the structure `/parc.com/index.html/version/segment/(hash_value)`.  The application emits a first Interest with the prefix `/parc.com/index.html` and (3,3) for the min/max suffix components and asks for right-most child.  A second system on the network responds with a corresponding Content Object, such as one named /parc.com/index.html/5/100/(hash_1).  Because this response may have come from cache, the consumer issues a second Interest for /parc.com/index.html, (3,3), right-most-child, and excludes up to and including 5.  This may cause the Interest to travel further in the network and thus discover a second Content Object `/parc.com/index.html/7/95/(hash_2)`.  The consumer would then issue a third Interest as before excluding up to and including 7.  If this Interest times out (there were not negative acknowledgements), then the consumer assumes it discovered the most recent version available in the connected network (another heuristic was if the Content Object was very recently signed, the consumer might accept it as current).  If the hash_2 version is acceptable (i.e. it verifies signature), then perhaps the consumer stops its discovery.  It may, however, want to check for duplicate names in which case it would issue another Interest for the name prefix `/parc.com/index.html/7/95` and exclude the singleton name component `hash_2`.  Perhaps there is a duplicate, named `/parc.com/index.html/7/95/(hash_3)`.  At this point, the application must determine which signature it prefers (if either) or apply another application-specific criteria.  Note that there could be more than 2 duplicate names and this process could repeat with another Interest that excludes both singletons `hash_2` and `hash_3`. -->

<!-- ### Other Interest fields -->

<!-- The PublisherPublicKeyDigest field will limit the set of matching Content Objects to those that have the specified publisher public key digest field.  It is an exact match.  This field is usually the SHA-256 digest of the publisher's public key. -->

<!-- The AnswerOriginKind can restrict where a Content Object comes from.  It is a bitmask that can choose from an in-network cache (content store), a dynamically generated response by a publisher, or that allows 'stale' cache answers (see Caching below). -->

<!-- The scope field is limits how far an Interest may travel.  The options are: local forwarder (but not other local applications), local applications, 1 network hop, and unlimited. -->

<!-- The InterestLifetime is request by the Interest issuer for how long the Interest should persist in the network (and thus be able to elicit a response).  No intermediate system is bound to honor that upper limit.  In some situations, this field was used like a subscription to get the next piece of content once it was published.  For example, a consumer has read the current temperature from a sensor, so it immediately issues a new Interest that excludes up to and including the current temperature version and asks to remain in the network for up to 10 seconds (a bit longer than the sensor period).  When the sensor creates the next Content Object 8 seconds later, there is already an Interest ready so the Content Object can move immediately. -->

<!-- The Nonce field is used to detect Interest loops.  It is a random number generated for each Interest.  Every forwarder that forwards an Interest keeps a history of Nonce values for what it considers long enough to detect loops.  If it detects a duplicate Nonce, it drops the Interest.  There were problems with Interest Aggregation combined with Nonce duplicate detection and multi-copy Interest forwarding that lead to undetected Interest drops (they were later worked around with the introduction of negative acknowledgements). -->

<!-- The FaceID field is used by an application to request the Interest be sent to a specific peer (or group).  It only has significance on the origin system to bypass normal forwarding table lookup. -->

### Forwarder Behavior

A CCNx 0.8 forwarder followed these steps to forward Interests and Content Objects:

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

<!-- ### Content Store -->

<!-- In CCNx 0.x, the Content Store is a non-persistent cache closely aligned with the forwarder.  A Content Object has one cache control directive, FreshnessSeconds.  This field, inside the signature envelope, is a relative time for how long a Content Object is considered 'fresh' in a Content Store.  If the field is not present, it is considered infinitely fresh.  At a forwarder, from the time a Content Object is most recently received and for the next FreshnessSeconds, the Content Object is marked as fresh.  After that period, it is marked as stale.  Normally, an Interest will only retrieve fresh Content Objects from a ContentStore, unless the AnswerOriginKind bitmask is set to include stale responses.  Note that in CCNx 0.x, a Content Object is infinitely valid, it has no hard expiry time.  The only distinction is fresh or stale. -->

<!-- ### Wireformat -->

<!-- The CCNx 0.x network protocol used an S-expression syntax encoded in its own proprietary binary protocol.  A full description of this format, known as CCNB, is available at https://github.com/PARC/ccnx-protocol-rfc/blob/master/Historical/mosko-ccnb-02.txt. -->

<!-- ## Recognized Issues with CCNx 0.8 -->

<!-- - There is a strong preference for the published naming convention, but there is no field in an Interest that says what naming convention is used.  If an application uses a different naming convention, it may cause undesired behavior from libraries that expected the normal convention. -->

<!-- - The use of command markers is ambiguous because binary name components may look like a command marker, especially if they are in a name component position where one would, by the normal naming convention, expect a certain field. -->

<!-- - Freshness Seconds is problematic when two otherwise equivalent interests are forwarded by a node, where one Interest allows stale and one Interest wants fresh.  There is no way for the intermediate node to know if a response came from a stale or fresh cache entry or from the producer itself. -->

<!-- - The CCNB wirefomat is difficult for a newcomer to understand.  Due to the strong application-layer framing, an application programmer (especially in the C library) needed to manually construct network-level packets using CCNB blocks. -->

<!-- - The time for Interest forwarding, without Content Store matching, is approximately O(1) in the PIT and approximately O(k) in the FIB, where k is the number of name components in the Interest (some strategies could reduce this to O(log k) via a binary search on the FIB).  The worst-case time for forwarding a Content Object, however, is O(n + n * m), where n is the number of PIT entries and m is the average number of exclusions per PIT entry.  This arises because in an adversarial environment an attacker could pollute the PIT with many Interest that all build off a similar name prefix, so a forwarder would need to iterate over all of them to determine if a Content Object specifically satisfied any of them. -->

<!-- - The 2-best-then-flood forwarding strategy is too chatty.  Especially when used to request content that does not yet exist, the Interest will by definition timeout and cause retransmission over the 2nd best, then flood over the remaining FIB entries.  This results in the Content Object, when finally produced, to likewise flood over all reverse paths and end up pretty much on every node in any of the forwarding paths.  In some early applications that issued such Interests for several associated Content Objects, it caused extreme network traffic.  Later implementations allowed for less chatty forwarding. -->

<!-- - The Child Inherit and Forward Capture flags combined with forwarding strategy (which could be one of several) combined with multipath and different length prefix registrations lead to a complex set of dependencies that is not well understood and could have unforeseen side effects especially when multiple applications are operating under the same prefix. -->

<!-- - Measuring round trip time for Interests based on FIB prefixes and lead to unexpected behavior.  FIB prefixes can be fairly short compared to application names, so it is entirely possible that a single FIB prefix will serve several traffic flows with different RTT characteristics.  For example, one flow could be static content that has a very short RTT and another could be dynamic content that has a much longer RTT.  Averaging these values will result in a RTT estimate in the middle that does not achieve the desired Interest timeout behavior for either flow. -->

<!-- - The combination of Interest Aggregation and Nonce duplicate detection, especially when combined with in-network Interest retransmission over multiple paths, can lead to a blackhole effect.  Imagine there are two paths from S to T.  An Interest from S travels along the first path, but times out as some intermediate node, which forwards the same Interest over the second path.  It is later dropped due to duplicate Nonce once the paths merge.  A third node, however, also sends a similar Interest over the second path and it gets aggregated with the retransmission.  That aggregated Interest will never be satisfied because it was dropped upstream due to duplicate None. -->

## Summary of NDN and CCNx 1.0 Evolution

### NDN Evolution

### CCNx 1.0 Evolution

The revision of CCNx 0.8 undertaken at PARC beginning in 2013, now called CCNx 1.0, refactored the protocol behavior with the objective to optimize performance and reduce the worst-case computational costs at a forwarder.
In more details, the changes are described in the next section, the following is a high-level summary:

- Constrained data retrieval only using `exact` or `full` names: such names needs to be communicated to parties by some other means (e.g., using an application-level discovery) or, in case of `exact` names, assigning same names to different pieces of data (different versions of data).

- Removed `Selectors` and introduced `Restrictors`: `hash restriction` as a replacement of the implicit hash digest name component in CCNx 0.8 and `KeyId` restriction with added semantics to the content store behavior.

- Changed packet format to be in "Type-Length-Value" encoding, with fixed encoding of `Type` and `Length` fields (2 octets each)

- Introduced a "fixed" common header, with optional hop-by-hop headers (not covered by signature)

- Removed "Nonce" from Interest

- Introduced "HopLimit"

- TBD
