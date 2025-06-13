# My Splunk + Sysmon SIEM Lab: Full Step-by-Step Guide

This document details the complete process I followed to build my SIEM detection lab.

## Table of Contents
1.  [Lab Architecture](#my-lab-architecture-and-components)
2.  [Step 1: Configure the Splunk Server](#step-1-configuring-the-splunk-server)
3.  [Step 2: Configure the Windows Endpoint](#step-2-configuring-the-windows-endpoint-sysmon)
4.  [Step 3: Configure the Splunk Forwarder](#step-3-configuring-the-splunk-universal-forwarder)
5.  [Step 4: Install the Splunk Add-on](#step-4-installing-the-splunk-add-on-for-sysmon)
6.  [Detection & Analysis Examples](#-detection--analysis-examples)

---

## My Lab Architecture and Components

My lab setup consists of three main components working together:

*   **Splunk Server**: A system running Splunk Enterprise (a free license is sufficient) that acts as my SIEM. It serves as both the indexer (receiving logs) and the search head (for analysis). I configured Splunk to listen for forwarded data on TCP port 9997.
*   **Windows Endpoint (Sysmon Host)**: A Windows 10/11 virtual machine that simulates a workstation in an enterprise environment. On this machine, I installed Microsoft Sysmon and the Splunk Universal Forwarder.
*   **Network Configuration**: The Splunk Server and Windows VM are on a private network (e.g., a host-only or NAT network in my hypervisor) where the Windows VM can reach the Splunk Server over port 9997.

<p align="center">
  <img src="./assets/lab-architecture.png" alt="Lab Architecture Diagram" width="700"/>
</p>

---

## Step 1: Configuring the Splunk Server

1.  **Install Splunk Enterprise**: I downloaded and installed Splunk Enterprise from the [official website](https://www.splunk.com/en_us/download/splunk-enterprise.html). The free license allows for up to 500 MB of data ingestion per day, which is more than enough for this lab.
2.  **Enable Receiving Port**: I configured Splunk to receive data from the forwarder.
    *   In the Splunk Web UI, I navigated to **Settings > Forwarding and Receiving**.
    *   Under "Receive data," I clicked **Add new**.
    *   I entered `9997` as the port and clicked Save. This opened the port to listen for incoming logs.
3.  **Create a Dedicated Index (Recommended)**: To keep my Sysmon data separate, I created a new index.
    *   I navigated to **Settings > Indexes**.
    *   I clicked **New Index**.
    *   I named the index `sysmon` and left the other settings as default, then clicked Save.

## Step 2: Configuring the Windows Endpoint (Sysmon)

1.  **Download Sysmon**: I obtained the Sysmon tool from the official [Microsoft Sysinternals page](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon).
2.  **Obtain a Sysmon Configuration File**: Sysmon's power comes from its configuration. Instead of starting from scratch, I used a robust community-provided configuration.
    *   **My Choice**: [SwiftOnSecurity's Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config). This config is widely used and provides excellent coverage of MITRE ATT&CK techniques while filtering out common noise.
    *   I downloaded the `sysmonconfig-export.xml` file and placed it on my Windows VM.
3.  **Install Sysmon**: I opened an **Administrator** command prompt or PowerShell and ran the following command to install Sysmon as a service using my chosen configuration file:
    ```powershell
    # Ensure you are in the same directory as Sysmon64.exe and the config file
    .\Sysmon64.exe -accepteula -i sysmonconfig-export.xml
    ```
4.  **Verify Sysmon is Running**: I checked that Sysmon was logging events correctly.
    *   I opened **Event Viewer**.
    *   I navigated to **Applications and Services Logs > Microsoft > Windows > Sysmon > Operational**.
    *   I could see events being logged. The image below shows an example of Sysmon Event ID 1 (Process Create), confirming that Sysmon was recording events on the endpoint.

    <p align="center">
      <img src="./assets/event-viewer-sysmon.png" alt="Sysmon Event in Event Viewer" width="700"/>
    </p>

## Step 3: Configuring the Splunk Universal Forwarder

1.  **Download and Install the Forwarder**: I got the [Splunk Universal Forwarder](https://www.splunk.com/en_us/download/universal-forwarder.html) installer (`.msi`) and ran it on my Windows VM.
    *   During the setup wizard, when prompted for the **Receiving Indexer**, I entered the IP address and port of my Splunk server (e.g., `192.168.1.10:9997`). This automatically configured the `outputs.conf` file.
2.  **Configure Log Collection**: After installation, the forwarder must be told *which* logs to collect. This is done by creating an `inputs.conf` file.
    *   I created a new file named `inputs.conf` in the following directory:
        `C:\Program Files\SplunkUniversalForwarder\etc\system\local\`
    *   The contents of this file are available in the `/configs` directory of the main repository.
3.  **Start/Restart the Forwarder**: I opened the `Services` app on Windows, found the `SplunkForwarder` service, and restarted it to apply the new configuration.

## Step 4: Installing the Splunk Add-on for Sysmon

Raw Sysmon events are in XML format. To make them useful, Splunk needs to parse them into fields. The **Splunk Add-on for Microsoft Sysmon** does exactly this.

1.  **Download the Add-on**: I grabbed the [Splunk Add-on for Microsoft Sysmon](https://splunkbase.splunk.com/app/1914) (ID 1914) from Splunkbase.
2.  **Install on the Splunk Server**:
    *   In my Splunk Web UI, I went to **Apps > Manage Apps**.
    *   I clicked **Install app from file**, chose the `.tgz` file I had downloaded, and uploaded it.
    *   I restarted Splunk when prompted.

## 🎯 Detection & Analysis Examples

With the lab fully configured, I was able to simulate attacker activity on the Windows VM and detect it in Splunk.

### Verifying Data in Splunk

I ran this search to see my Sysmon data flowing into the `sysmon` index:

```spl
index=sysmon sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational"
```
The search returned events, and on the left side, I saw a list of "Interesting Fields" like `EventCode`, `Image`, and `User`, which confirmed the Add-on was working correctly.

<p align="center">
  <img src="./assets/splunk-search-interface.png" alt="Splunk Search Interface" width="700"/>
</p>

### Example 1: Detecting Obfuscated PowerShell

*   **Simulation (on Windows VM)**:
    ```powershell
    powershell.exe -EncodedCommand "dABoAG8AYQBtAGkA"
    ```
*   **Detection (in Splunk)**:
    ```spl
    index=sysmon EventCode=1 Image="*\\powershell.exe" (CommandLine="*-enc*" OR CommandLine="*-EncodedCommand*")
    ```

### Example 2: Detecting Batch Scripts in Suspicious Locations

*   **Simulation (on Windows VM)**:
    *   I created a file named `malicious.bat` in `C:\Users\Public\`.
    *   I added a simple command like `net user` to it and ran it.
*   **Detection (in Splunk)**:
    ```spl
    index=sysmon EventCode=1 Image="*\\cmd.exe" CommandLine="*.bat*"
    | where NOT (CommandLine LIKE "C:\\Windows\\%" OR CommandLine LIKE "C:\\Program Files\\%")
    ```

### Example 3: Detecting Executables Dropped in Temp Folders

*   **Simulation (on Windows VM)**:
    ```powershell
    New-Item -Path C:\Windows\Temp\malware.exe -ItemType File
    ```
*   **Detection (in Splunk)**:
    ```spl
    index=sysmon EventCode=11 TargetFilename IN ("C:\\Windows\\Temp\\*.exe", "C:\\Users\\*\\AppData\\Local\\Temp\\*.exe")
    ```

### Example 4: Detecting Suspicious Network Connections

*   **Simulation (on Windows VM)**:
    ```powershell
    Invoke-WebRequest -Uri "http://<some-ip>"
    ```
*   **Detection (in Splunk)**:
    ```spl
    index=sysmon EventCode=3
    | where Image NOT IN ("*\\chrome.exe", "*\\firefox.exe", "*\\msedge.exe")
    ```

---
**(Note: You can include the full list of references from the PDF here at the bottom of the tutorial if you wish)**
