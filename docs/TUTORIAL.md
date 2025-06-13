# My Splunk + Active Directory Detection Lab: Full Illustrated Guide

This document details the complete process I followed to build my advanced SIEM detection lab. This project integrates a full Microsoft Active Directory environment, enabling realistic attack simulation and detection scenarios.

## Table of Contents
1.  [Lab Architecture & Components](#-lab-architecture--components)
2.  [Part 1: The Foundation - Virtual Environment Setup](#part-1-the-foundation---virtual-environment-setup)
3.  [Part 2: The Domain - Building the Active Directory Environment](#part-2-the-domain---building-the-active-directory-environment)
4.  [Part 3: The SIEM - Splunk & Endpoint Configuration](#part-3-the-siem---splunk--endpoint-configuration)
5.  [Part 4: The Arsenal - Attacker & Testing Frameworks](#part-4-the-arsenal---attacker--testing-frameworks)
6.  [Part 5: The Hunt - Attack Simulation & Detection](#part-5-the-hunt---attack-simulation--detection)

---

## 📝 Lab Architecture & Components

My lab consists of four virtual machines operating within a private NAT network, creating an isolated but realistic enterprise environment.

<p align="center">
  <img src="./assets/lab-architecture.png" alt="Lab Architecture Diagram" width="800"/>
</p>

*   **Windows Server 2022 (ADDC01):** The Domain Controller, serving `d3vhackz.local`.
*   **Ubuntu Server (Splunk Server):** Hosts the Splunk Enterprise instance for log collection and analysis.
*   **Windows 10 (Target Machine):** A domain-joined workstation where attacks are simulated.
*   **Kali Linux (Attacker Machine):** Used to launch attacks against the environment.

---

## Part 1: The Foundation - Virtual Environment Setup

### 1.1 VirtualBox Network Configuration
I created a dedicated NAT Network in VirtualBox to ensure all VMs could communicate.

<p align="center">
  <img src="./assets/virtualbox-nat-network-setup.png" alt="VirtualBox NAT Network Setup" width="700"/>
</p>

### 1.2 Virtual Machine Creation
I created the four base VMs, attaching each to my custom NAT Network.

<p align="center">
  <img src="./assets/virtualbox-vm-list.png" alt="List of Virtual Machines" width="700"/>
  <br>
  <em>My final set of virtual machines ready for configuration.</em>
</p>

---

## Part 2: The Domain - Building the Active Directory Environment

### 2.1 Setting up the Domain Controller (ADDC01)
1.  **Install AD DS Role:** On the Windows Server VM, I used Server Manager to add the "Active Directory Domain Services" role.

    <p align="center">
      <img src="./assets/windows-server-add-roles.png" alt="Adding AD DS Role" width="700"/>
    </p>

2.  **Promote to Domain Controller:** I promoted the server to a new domain controller.

    <p align="center">
      <img src="./assets/windows-server-promote-dc.png" alt="Promoting Server to a Domain Controller" width="700"/>
    </p>

3.  **Create New Forest:** I created a new forest with the root domain name `d3vhackz.local`.

    <p align="center">
      <img src="./assets/windows-server-create-domain.png" alt="Creating the new d3vhackz.local domain" width="700"/>
    </p>

4.  **Populate Users:** In "Active Directory Users and Computers," I created several accounts.

    <p align="center">
      <img src="./assets/windows-server-ad-users-computers.png" alt="Creating users in Active Directory" width="700"/>
    </p>

### 2.2 Joining the Windows 10 Endpoint to the Domain
Finally, I joined the Windows 10 machine to the `d3vhackz.local` domain.

<p align="center">
  <img src="./assets/windows-10-join-domain.png" alt="Joining Windows 10 to the domain" width="700"/>
</p>

---

## Part 3: The SIEM - Splunk & Endpoint Configuration

### 3.1 Splunk Server Configuration
*   I accessed the Splunk web interface at `http://192.168.10.10:8000`.
*   I enabled port **9997** for data receiving via **Settings > Forwarding and receiving**.
*   I created a new index named `endpoint` via **Settings > Indexes**.

<p align="center">
  <img src="./assets/splunk-create-index.png" alt="Creating a new index in Splunk" width="700"/>
</p>

### 3.2 Windows Endpoint Configuration (ADDC01 & Target-PC)
1.  **Install Sysmon:** I downloaded Sysmon and a community configuration, then installed it via an administrative PowerShell.

    <p align="center">
      <img src="./assets/sysmon-install-command.png" alt="Installing Sysmon from PowerShell" width="700"/>
    </p>

2.  **Install Splunk Universal Forwarder:** I installed the agent on each Windows machine, pointing it to my Splunk Server's IP (`192.168.10.10`) during setup.

    <p align="center">
      <img src="./assets/splunk-uf-installer-setup.png" alt="Configuring the Splunk Forwarder with the indexer IP" width="700"/>
    </p>

3.  **Configure `inputs.conf`:** I created an `inputs.conf` file to forward Sysmon, Security, and Application logs to the `endpoint` index.

    <p align="center">
      <img src="./assets/endpoint-inputs-conf.png" alt="inputs.conf configuration" width="700"/>
    </p>

---

## Part 4: The Arsenal - Attacker & Testing Frameworks

### 4.1 Kali Linux Setup
On the Kali VM, I installed `crowbar` for RDP brute-force testing and prepared a password list.

<p align="center">
  <img src="./assets/kali-install-tools.png" alt="Installing crowbar on Kali Linux" width="700"/>
</p>

<p align="center">
  <img src="./assets/kali-password-list-setup.png" alt="Creating a password list on Kali" width="700"/>
</p>

### 4.2 Atomic Red Team Setup
On the Windows 10 endpoint, I installed the **Atomic Red Team** framework.

1.  **Installation:** I ran the official installation command in PowerShell.

    <p align="center">
      <img src="./assets/atomic-red-team-install.png" alt="Installing Atomic Red Team via PowerShell" width="700"/>
    </p>

2.  **Defender Exclusion:** I added an exclusion for the `C:\` folder to allow the tests to run unimpeded in my lab environment.

    <p align="center">
      <img src="./assets/atomic-defender-exclusion.png" alt="Adding a Defender exclusion" width="700"/>
    </p>

---

## Part 5: The Hunt - Attack Simulation & Detection

### Scenario 1: Create Account (T1136.001) with Atomic Red Team
1.  **Execution:** I used Atomic Red Team to simulate an attacker creating a local user, mapping to MITRE ATT&CK technique T1136.

    <p align="center">
      <img src="./assets/mitre-t1136-create-account.png" alt="MITRE ATT&CK T1136" width="700"/>
    </p>
    <p align="center">
      <img src="./assets/atomic-invoke-t1136.png" alt="Executing an Atomic Red Team test for T1136" width="700"/>
    </p>

2.  **Detection:** I searched in Splunk for Event ID `4720` ("A user account was created"). The event for `NewLocalUser` appeared instantly.

    <p align="center">
      <img src="./assets/splunk-detect-event-id-4720.png" alt="Detecting Event ID 4720 in Splunk" width="700"/>
    </p>

### Scenario 2: RDP Brute-Force Attack from Kali Linux
1.  **Execution:** From my Kali machine, I used `crowbar` to launch an RDP brute-force attack, which successfully found a valid password.

    <p align="center">
      <img src="./assets/kali-rdp-brute-force.png" alt="Launching an RDP brute-force attack" width="700"/>
    </p>

2.  **Detection:** The attack created a storm of failed logins.
    *   **Local Evidence:** Windows Event Viewer was flooded with **Event ID 4625 (An account failed to log on)**.
    *   **SIEM Detection:** In Splunk, a simple search for `index=endpoint EventCode=4625` clearly exposed the attack, revealing thousands of failures originating from the Kali machine's IP.

    <p align="center">
      <img src="./assets/event-viewer-logon-failure-detail.png" alt="Audit Failures in Windows Event Viewer" width="700"/>
      <br>
      <em>The local Event Viewer shows clear evidence of the attack.</em>
    </p>
    <p align="center">
      <img src="./assets/splunk-detect-logon-failure-4625.png" alt="Detecting logon failures in Splunk" width="700"/>
      <br>
      <em>Aggregating these events in Splunk makes the brute-force attempt undeniable.</em>
    </p>

This walkthrough demonstrates a complete, end-to-end detection engineering workflow, from building the environment to catching the simulated attackers.