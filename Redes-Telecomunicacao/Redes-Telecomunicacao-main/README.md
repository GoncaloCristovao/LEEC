# Enterprise Network Architecture & Hybrid Client-Server Infrastructure

This repository contains the complete network architecture design, hierarchical routing configuration, dual-stack addressing planning, and socket communication developed for the **Redes de Telecomunicações** (Telecommunication Networks) curricular unit at the University of Aveiro (DETI).

The project implemented an enterprise network infrastructure (**BestGadget Inc.**) emulated in GNS3, featuring inter-VLAN routing, dynamic OSPF routing, public/private translation, and hybrid bridging to communicate with external host server applications via TCP/IP sockets.

---

##  Network Architecture & Topology Overview

The infrastructure connects multiple corporate departments across distinct physical zones and routing areas:
* **Development Department:** VLAN 10 (Design & Specs), VLAN 20 (Hardware Teams), VLAN 30 (Software Teams), and VLAN 40 (Test Teams).
* **Main Building:** Office and Executive Management subnets.
* **Data Center & IT:** Dedicated server farm (VLAN 100) and network administration (VLAN 50).
* **Core & Distribution Layer:** Multi-router backbone based on Cisco 7200 platforms (BGI1, BGI2, BGI3) and an EtherSwitch router (BGI-ESW).

```text
[ External Server / Host Machine ]
                │  (Bridge / Loopback Interface)
          [ GNS3 Cloud ]
                │
         [ BGI1-C7200 ] (NAT/PAT & Edge Gateway)
         /            \
  [ BGI2-C7200 ] ──── [ BGI3-C7200 ]
         \            /
         [ BGI-ESW Router ]
          /    |    |    \
     [VLAN10] [VLAN20] [VLAN30] [VLAN40] (Hosts / End-Devices)
