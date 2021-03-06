# Introduction

NDN and CCNx 1.0 are two prominent realizations of the Information-Centric Networking (ICN) vision.
Both realizations share the same root of Content Centric Networking (CCN) design introduced by [Van Jacobson in 2006](http://www.ccnx.org/395/1/van-jacobsen-at-google/).
<!-- CCNx -->
CCNx, from versions 0.1 to 0.8 (referred to as CCNx 0.x in the rest of this draft), was the name of the software router and libraries developed and maintained by PARC.
Although the protocol architecture was renamed to NDN when the effort got funded under NSF’s Future Internet Architecture (FIA) program in 2010 (with PARC being one of the ten funded institutions), the NDN project used CCNx 0.x as its implementation in its first two years of operation, and PARC provided the codebase support to meet the research needs for the rest of the project team.

In October 2012, PARC parted the way from the rest of the NDN project team in (interested readers may take a look at [the related causes](https://named-data.net/wp-content/uploads/2016/08/NDN-IPR.pdf)).
In 2013 PARC introduced a significantly re-designed, non-backward-compatible protocol CCNx 1.0, which was acquired by Cisco Systems in 2017.

In parallel, the NDN project team has been continuing to refine the NDN protocol derived from the original CCNx 0.x design, guided by the [NDN protocol design principles](https://named-data.net/project/ndn-design-principles/) and based on experimentation results.

The objective of this document is to summarize the shared commonalities between the latest versions of NDN and CCNx 1.0 realizations, identify points of divergence, and documents reasons behind these different design choices.
The identified commonalities and differences serve as a starting point to an open discussion to determine possibility to harmonize the two realizations, and if determined so, provide a general guidance on how to achieve it.

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](#RFC2119).

ICN terms used in this document are interpreted as described in [](#I-D.wissingh-icnrg-terminology).

