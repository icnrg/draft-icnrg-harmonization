# Introduction

Content-Centric Networking version 1.0 (CCNx 1.0) and Named Data Networking (NDN) are two prominent realizations of the Information-Centric Networking (ICN) architecture.
Both realizations share the same roots of Content Centric Networking (CCN) idea introduced by [Van Jacobson in 2006](http://www.ccnx.org/395/1/van-jacobsen-at-google/).
<!-- CCNx -->
<!-- Up until version 0.8, CCNx was a prototype of the NDN/CCN architecture. -\-> -->
CCNx was the name for the software router and libraries developed and maintained by PARC, realizing a version of CCN/NDN protocol in versions 0.1-0.8, later referred as CCNx 0.x in this draft.
NDN (Named Data Networking) name was introduced as part of NSF FIA project and effectively became a new generalized name for overall CCN architecture.

Starting 2012, because of multiple reasons, including [patent concerns](https://named-data.net/wp-content/uploads/2016/08/NDN-IPR.pdf), CCNx and NDN communities to some extent diverge.
PARC introduced a significantly re-designed version of CCNx realization (CCNx 1.0) and NDN team (participants of NSF FIA projects and other community collaborators) pushed forward an updated version of the NDN architecture, highlighting value of [protocol design principles](https://named-data.net/project/ndn-design-principles/).

The objective of this document is to summarize the shared commonalities between the latest versions of CCNx and NDN realizations, identify points of divergence, and documents reasons for the divergence.
The identified commonalities and differences serve as a starting point to an open discussion to determine possibility to "harmonize" the two realizations, and if determined so, provide a general guidance on how to achieve it.

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](#RFC2119).

ICN terms used in this document are interpreted as described in [](#I-D.wissingh-icnrg-terminology).

