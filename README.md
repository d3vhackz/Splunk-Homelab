Of course. The current README.md is a good starting point, but we can make it significantly more impactful for hiring managers and networking.

A great project README should be a self-contained showcase. It needs to immediately grab attention, explain the project's value, demonstrate the process, and highlight the skills you've acquired—all without forcing the reader to click away to another site.

Here is a completely revamped README.md. It incorporates the detailed guide from your Notion page, adds professional formatting, and is structured to impress.

Instructions for You:

Copy and Paste: Copy the entire content below and paste it into the README.md file in your GitHub repository.

Add Images: I have included placeholders like ![Lab Architecture](images/lab-architecture.png).

Create a folder named images in your repository.

Download the images from your Notion page and upload them to this images folder.

Ensure the file names in the Markdown match the file names you upload.

Update YouTube Link (Optional): The YouTube link is already included. You can replace the thumbnail link if you want a custom one.

New README.md Content:
# Splunk SIEM & Sysmon Detection Lab

![Splunk](https://img.shields.io/badge/Splunk-000000?style=for-the-badge&logo=splunk&logoColor=white)
![Sysmon](https://img.shields.io/badge/Sysmon-1E5693?style=for-the-badge&logo=windows&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Atomic Red Team](https://img.shields.io/badge/Atomic_Red_Team-D22B2B?style=for-the-badge)

This project documents the creation of a fully operational security lab designed to simulate a real-world enterprise environment. By integrating Splunk as a SIEM and Sysmon for deep endpoint telemetry, this lab provides a platform for hands-on experience in threat detection, data analysis, and security engineering.

The primary objective is to ingest, parse, and analyze security event data from a Windows endpoint to detect malicious activities simulated using the Atomic Red Team framework, which executes tests based on the MITRE ATT&CK framework.

## Live Project Demo

For a quick overview and a demonstration of the lab in action, please watch the video below.

<a href="https://www.youtube.com/watch?v=0e3W2wve1T4" target="_blank">
 <img src="http://img.youtube.com/vi/0e3W2wve1T4/maxresdefault.jpg" alt="Watch the video" width="720" height="480" border="10" />
</a>

## Table of Contents
- [Lab Architecture](#lab-architecture)
- [Core Technologies & Tools](#core-technologies--tools)
- [Project Walkthrough](#project-walkthrough)
  - [Phase 1: Virtual Lab & Network Setup](#phase-1-virtual-lab--network-setup)
  - [Phase 2: Splunk Enterprise (SIEM) Installation](#phase-2-splunk-enterprise-siem-installation)
  - [Phase 3: Sysmon Endpoint Monitoring Setup](#phase-3-sysmon-endpoint-monitoring-setup)
  - [Phase 4: Configuring the Splunk Universal Forwarder](#phase-4-configuring-the-splunk-universal-forwarder)
  - [Phase 5: Verifying Data Ingestion](#phase-5-verifying-data-ingestion)
- [Threat Simulation & Detection Example](#threat-simulation--detection-example)
  - [Scenario: PowerShell Download Cradle (T1059.001)](#scenario-powershell-download-cradle-t1059001)
  - [Detection with Splunk Processing Language (SPL)](#detection-with-splunk-processing-language-spl)
- [Conclusion & Key Skills Demonstrated](#conclusion--key-skills-demonstrated)


## Lab Architecture

The lab is built on a private virtual network to ensure all simulated attacks are isolated. It consists of two primary machines:

1.  **SIEM Server (Windows Server 2019):** This VM hosts Splunk Enterprise, acting as our centralized logging and analysis platform. It listens for incoming data from our monitored endpoint.
2.  **Victim Endpoint (Windows 10):** This VM represents a typical corporate workstation. It is configured with Sysmon for advanced event logging and a Splunk Universal Forwarder to send this data to the SIEM.

![Lab Architecture Diagram](images/lab-architecture.png)

## Core Technologies & Tools

| Technology           | Role & Purpose                                                                                          |
| -------------------- | ------------------------------------------------------------------------------------------------------- |
| **VMware Workstation** | Hypervisor used to create and manage the virtual machines for the lab environment.                      |
| **Windows Server 2019**| Operating system for the SIEM server, providing a stable platform for Splunk Enterprise.                |
| **Windows 10**         | Operating system for the "victim" endpoint, which we monitor for suspicious activity.                   |
| **Splunk Enterprise**  | The core SIEM platform for collecting, indexing, searching, and visualizing security data.              |
| **Sysmon**             | A powerful Windows monitoring tool that provides deep visibility into process creation, network traffic, and file system changes. |
| **Splunk Universal Forwarder** | A lightweight agent deployed on the endpoint to efficiently forward log data to Splunk.         |
| **Atomic Red Team**    | A PowerShell-based framework used to safely execute tests mapped to the MITRE ATT&CK framework, simulating real-world attacker TTPs. |

## Project Walkthrough

### Phase 1: Virtual Lab & Network Setup
The foundation of the lab is a properly configured virtual environment.

1.  **VM Creation:** Two VMs were created in VMware: one for Windows Server 2019 (SIEM) and one for Windows 10 (Endpoint).
2.  **Network Isolation:** Both VMs were configured to use a private network segment (`Host-Only` or `LAN Segment`) to isolate them from the host machine and external networks.
3.  **Static IP & Connectivity:** Static IP addresses were assigned to ensure stable communication:
    *   **SIEM Server:** `192.168.10.100`
    *   **Victim Endpoint:** `192.168.10.110`
4.  **Firewall Configuration:** For initial setup, the Windows Defender Firewall was temporarily disabled on both VMs. In a production environment, specific rules for ports `9997` (Splunk data) and `8089` (Splunk management) would be created.
5.  **Connectivity Test:** A `ping` command was used to verify that the two VMs could communicate successfully over the private network.

![Image: Pinging between VMs to verify connectivity](images/vm-ping-test.png)

### Phase 2: Splunk Enterprise (SIEM) Installation
With the server VM ready, Splunk Enterprise was installed and configured.

1.  **Installation:** The Splunk Enterprise `.msi` installer was downloaded and run on the Windows Server 2019 VM. A secure administrator password was created during the setup.
2.  **Configure Data Receiving:** To accept logs from the Universal Forwarder, a data receiving port was enabled in Splunk.
    *   Navigated to **Settings > Forwarding and receiving**.
    *   Configured a new receiving port on `9997`, the default port for Splunk forwarders.

![Image: Configuring Splunk to receive data on port 9997](images/splunk-receiving-port.png)

### Phase 3: Sysmon Endpoint Monitoring Setup
To get meaningful data, the Windows 10 endpoint was instrumented with Sysmon.

1.  **Download Sysmon & Config:** The Sysmon utility and a robust configuration file from [SwiftOnSecurity](https://github.com/SwiftOnSecurity/sysmon-config) were downloaded. This config file is crucial as it filters out benign system noise, focusing on potentially malicious events.
2.  **Installation:** Using an administrative PowerShell, Sysmon was installed with the custom configuration file. This ensures that the generated logs are rich in security context.
    ```powershell
    # The command used to install Sysmon with a specific configuration
    .\Sysmon64.exe -accepteula -i C:\Sysmon\sysmonconfig-export.xml
    ```

![Image: Sysmon installation command in PowerShell](images/sysmon-install-command.png)

### Phase 4: Configuring the Splunk Universal Forwarder
A Universal Forwarder (UF) was installed on the Windows 10 endpoint to ship Sysmon logs to the SIEM.

1.  **UF Installation:** The UF installer was run on the Windows 10 VM. During setup, it was configured to point to the SIEM server:
    *   **Deployment Server:** `192.168.10.100:8089`
    *   **Receiving Indexer:** `192.168.10.100:9997`
2.  **Data Input Configuration:** The UF was instructed which logs to monitor. Using the command line, the Sysmon event log was added as a data source.
    ```powershell
    # Navigate to the UF's bin directory
    cd "C:\Program Files\SplunkUniversalForwarder\bin"

    # Add the Sysmon log source and assign an index and sourcetype
    .\splunk.exe add monitor "Microsoft-Windows-Sysmon/Operational" -index botsv3 -sourcetype "XmlWinEventLog:Microsoft-Windows-Sysmon/Operational"

    # Restart the service to apply changes
    .\splunk.exe restart
    ```

### Phase 5: Verifying Data Ingestion
The final setup step was to confirm that logs were successfully flowing from the endpoint to Splunk.

1.  **Splunk Search:** In the Splunk Search & Reporting app, a query was run to check for data in the newly created index.
    ```spl
    index="botsv3"
    ```
2.  **Confirmation:** Events from the Windows 10 machine appeared in the search results, confirming that the data pipeline was working correctly.

![Image: Verifying Sysmon data is arriving in Splunk](images/splunk-data-verification.png)

## Threat Simulation & Detection Example

This section demonstrates the core value of the lab: detecting a simulated threat.

### Scenario: PowerShell Download Cradle (T1059.001)
A common attack technique is to use PowerShell to download and execute malicious scripts from the internet. We simulated this using Atomic Red Team.

1.  **Install Atomic Red Team:** The framework was installed on the Windows 10 endpoint via PowerShell.
    ```powershell
    Install-Module -Name AtomicRedTeam -Force
    ```
2.  **Execute Test:** The specific test for a PowerShell download cradle was invoked.
    ```powershell
    Invoke-AtomicTest T1059.001 -TestNumbers 3
    ```
    This command safely executes a `IEX (New-Object Net.WebClient).DownloadString(...)` command, a classic indicator of compromise (IOC).

![Image: Executing an Atomic Red Team test](images/atomic-red-team-execution.png)

### Detection with Splunk Processing Language (SPL)
With the "attack" executed, I pivoted to Splunk to hunt for the evidence. Sysmon `EventCode=1` (Process Creation) is perfect for this, as it captures the full command line of every process.

The following SPL query was crafted to find this specific behavior:

```spl
index="botsv3" source="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=1 CommandLine="*IEX*"
```

**Query Breakdown:**
*   `index="botsv3"`: Focuses the search on our dedicated index.
*   `EventCode=1`: Filters for only "Process Creation" events from Sysmon.
*   `CommandLine="*IEX*"`: Searches the `CommandLine` field for the presence of `IEX` (Invoke-Expression), a strong indicator of this technique.

**Result:** The query returned the exact event generated by the Atomic Red Team test, successfully detecting the simulated threat. The results clearly showed `powershell.exe` executing the malicious command line.

![Image: Splunk search results showing the detected malicious command](images/splunk-detection-result.png)

## Conclusion & Key Skills Demonstrated

This project serves as a practical application of the tools and methodologies used daily in a Security Operations Center (SOC). It successfully established an end-to-end security monitoring pipeline and proved its effectiveness by detecting a simulated TTP.

**Skills and Competencies Showcased:**
*   **SIEM Deployment & Administration:** Installed, configured, and managed a Splunk Enterprise instance for log collection and analysis.
*   **Endpoint Detection & Monitoring:** Deployed and configured Sysmon with custom rules to gain deep visibility into endpoint activity.
*   **Log Management & Data Pipelining:** Established a reliable data flow from an endpoint to a central SIEM using the Splunk Universal Forwarder.
*   **Detection Engineering:** Authored custom detection rules using Splunk Processing Language (SPL) to identify specific malicious behaviors.
*   **Threat Emulation:** Utilized the Atomic Red Team framework to simulate attacker techniques mapped to the MITRE ATT&CK framework.
*   **Security Analysis:** Investigated events and distinguished malicious activity from benign system noise.

### Future Improvements
-   **Develop Splunk Alerts:** Convert the detection query into a real-time alert to automate threat notification.
-   **Create Security Dashboards:** Build visualizations to track key security metrics and trends.
-   **Expand Log Sources:** Ingest additional data sources, such as Windows Security Logs, PowerShell logs, and firewall logs, for comprehensive visibility.
-   **Advanced Detections:** Write more complex correlation searches to detect multi-stage attack chains.
