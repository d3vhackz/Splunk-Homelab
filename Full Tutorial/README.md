# Building a Splunk SIEM & Sysmon Detection Lab

This repository documents the step-by-step process of building a fully functional Security Information and Event Management (SIEM) lab using Splunk and Sysmon. The primary goal of this project is to create a controlled environment for detecting, analyzing, and responding to simulated cyber threats, mirroring a real-world Security Operations Center (SOC) setup.

This lab is designed to ingest detailed endpoint telemetry from a Windows machine using Sysmon, forward it to a Splunk instance for indexing and analysis, and then use the Splunk Processing Language (SPL) to query the data and identify malicious activity simulated with the Atomic Red Team framework.

## Table of Contents
- [Project Objectives](#project-objectives)
- [Technologies & Tools Used](#technologies--tools-used)
- [Lab Architecture](#lab-architecture)
- [Phase 1: Virtual Lab Setup](#phase-1-virtual-lab-setup)
- [Phase 2: Splunk Enterprise Installation (SIEM)](#phase-2-splunk-enterprise-installation-siem)
- [Phase 3: Sysmon Installation & Configuration (Endpoint Telemetry)](#phase-3-sysmon-installation--configuration-endpoint-telemetry)
- [Phase 4: Splunk Universal Forwarder Setup (Log Forwarding)](#phase-4-splunk-universal-forwarder-setup-log-forwarding)
- [Phase 5: Data Ingestion & Verification](#phase-5-data-ingestion--verification)
- [Phase 6: Threat Simulation & Detection](#phase-6-threat-simulation--detection)
- [Conclusion & Future Improvements](#conclusion--future-improvements)

## Project Objectives
*   **Build a Core Security Capability:** Deploy and configure a SIEM, a foundational tool for any security team.
*   **Gain Endpoint Visibility:** Utilize Sysmon to gain deep insight into system-level activity on a Windows endpoint.
*   **Master Data Pipelining:** Understand and implement the process of forwarding logs from a source to a central SIEM.
*   **Develop Detection Engineering Skills:** Write custom detection rules using SPL to identify specific threat behaviors.
*   **Simulate Real-World Threats:** Use Atomic Red Team to safely execute TTPs (Tactics, Techniques, and Procedures) from the MITRE ATT&CK framework.
*   **Enhance Analytical Skills:** Analyze query results to distinguish malicious activity from benign system noise.

## Technologies & Tools Used

| Tool                 | Purpose                                                                                                 | Operating System |
| -------------------- | ------------------------------------------------------------------------------------------------------- | ---------------- |
| **VMware Workstation** | Hypervisor for creating and managing virtual machines.                                                  | Host OS          |
| **Windows 10/11**    | The "Victim" machine. The endpoint we will monitor for malicious activity.                                | Guest OS         |
| **Windows Server 2019**| The "SIEM Server" hosting our Splunk instance.                                                          | Guest OS         |
| **Splunk Enterprise**| The SIEM platform used for collecting, indexing, searching, and analyzing log data.                     | Windows Server   |
| **Sysmon**           | A powerful Windows system service that provides detailed information about process creations, network connections, and changes to the file system. | Windows 10/11      |
| **Splunk Universal Forwarder** | A lightweight agent deployed on endpoints to forward log data to a Splunk indexer.              | Windows 10/11      |
| **Atomic Red Team**  | A PowerShell-based framework for executing simple, automatable tests mapped to the MITRE ATT&CK framework. | Windows 10/11      |

## Lab Architecture

The lab operates on a private virtual network to ensure a safe and isolated environment for threat simulation. The architecture consists of three main components:

1.  **SIEM Server (Windows Server 2019):** This machine runs Splunk Enterprise and acts as our central log collection and analysis platform.
2.  **Victim Endpoint (Windows 10):** This machine is our monitored endpoint. It runs Sysmon to generate rich security events and a Splunk Universal Forwarder to send those events to the SIEM.
3.  **Attacker (Implicit):** We act as the attacker by executing commands directly on the Victim Endpoint using frameworks like Atomic Red Team.

![Lab Architecture Diagram](images/lab-architecture.png)

---

## Phase 1: Virtual Lab Setup

The first step is to create the virtual machines (VMs) and configure the network.

**1. Create the SIEM Server:**
   - In VMware, create a new VM.
   - Install **Windows Server 2019**.
   - Allocate sufficient resources (e.g., 2-4 vCPUs, 8GB RAM, 80GB HDD). Splunk can be resource-intensive.
   - Set the network adapter to a **private network** (e.g., LAN segment or Host-Only) to isolate it from your main network.

**2. Create the Victim Endpoint:**
   - Create a second VM.
   - Install **Windows 10 or 11**.
   - Allocate standard resources (e.g., 2 vCPUs, 4GB RAM, 60GB HDD).
   - Connect this VM to the **same private network** as the SIEM Server.

**3. Network Configuration & Verification:**
   - **Assign Static IPs:** Manually configure the IP addresses for both VMs to ensure stable communication. For example:
     - **SIEM Server (Windows Server):** `192.168.10.100`
     - **Victim Endpoint (Windows 10):** `192.168.10.110`
   - **Disable Firewalls (for lab purposes only):** To simplify setup, temporarily disable the Windows Defender Firewall on both VMs. **In a production environment, you would create specific firewall rules instead.**
   - **Verify Connectivity:** Open Command Prompt on one VM and ping the other to ensure they can communicate.
     ```powershell
     ping 192.168.10.100
     ```

![Image: Pinging between VMs to verify connectivity](images/vm-ping-test.png)

---

## Phase 2: Splunk Enterprise Installation (SIEM)

Now we'll install and configure Splunk on our Windows Server VM.

**1. Download Splunk Enterprise:**
   - On the Windows Server VM, browse to the [Splunk Enterprise Free Trial page](https://www.splunk.com/en_us/download/splunk-enterprise.html).
   - Register for an account and download the Windows `.msi` installer.

**2. Install Splunk:**
   - Run the installer.
   - Accept the license agreement.
   - Choose a username and a strong password for the Splunk administrator account. **Remember this password!**
   - The installation will proceed and Splunk will start automatically.

![Image: Splunk Enterprise installation wizard](images/splunk-install-wizard.png)

**3. Configure Data Ingestion:**
   - Once Splunk is running, it will open in your web browser at `http://localhost:8000`. Log in with the credentials you just created.
   - We need to configure Splunk to listen for data from our Universal Forwarder.
   - Go to **Settings > Forwarding and receiving**.
   - Under "Receive data," click **Configure receiving**.
   - Click **New Receiving Port**.
   - Enter `9997` as the port number and click **Save**. This is the default port Splunk uses for receiving forwarded data.

![Image: Configuring Splunk to receive data on port 9997](images/splunk-receiving-port.png)

---

## Phase 3: Sysmon Installation & Configuration (Endpoint Telemetry)

Next, we'll install Sysmon on the Windows 10 "Victim" machine to generate the high-quality logs we want to analyze.

**1. What is Sysmon?**
   - **System Monitor (Sysmon)** is a free tool from the Windows Sysinternals suite. It logs detailed information about process creation (including command lines and parent processes), network connections, file creation events, and more. This level of detail is essential for effective threat hunting and is often missing from standard Windows event logs.

**2. Download Sysmon and a Configuration File:**
   - On the Windows 10 VM, download the [Sysmon utility from Microsoft](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon).
   - **Using a good configuration file is crucial.** A default Sysmon installation is too noisy. We will use a popular, well-maintained configuration by SwiftOnSecurity, which filters out benign noise and focuses on suspicious events.
   - Download the config file: [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)
   - Save both `Sysmon64.exe` and the `sysmonconfig-export.xml` file to the same directory (e.g., `C:\Sysmon`).

**3. Install Sysmon:**
   - Open an **administrative PowerShell or Command Prompt**.
   - Navigate to the directory where you saved the files.
   - Run the following command to install Sysmon with the custom configuration:
     ```powershell
     .\Sysmon64.exe -accepteula -i C:\Sysmon\sysmonconfig-export.xml
     ```
   - You can verify the installation by checking the Event Viewer under `Applications and Services Logs/Microsoft/Windows/Sysmon/Operational`.

![Image: Sysmon installation command in PowerShell](images/sysmon-install-command.png)

---

## Phase 4: Splunk Universal Forwarder Setup (Log Forwarding)

The Universal Forwarder (UF) is a lightweight agent that we install on the Windows 10 machine to collect logs and send them to our Splunk server.

**1. Download the Universal Forwarder:**
   - On the Windows 10 VM, browse to the [Splunk Universal Forwarder download page](https://www.splunk.com/en_us/download/universal-forwarder.html).
   - Download the Windows `.msi` installer.

**2. Install the Universal Forwarder:**
   - Run the installer.
   - Accept the license agreement.
   - On the "Deployment Server" screen, enter the IP and management port of your Splunk server: `192.168.10.100:8089`.
   - On the "Receiving Indexer" screen, enter the IP and receiving port: `192.168.10.100:9997`.
   - Complete the installation.

**3. Configure the Forwarder to Send Sysmon Logs:**
   - We now need to tell the UF *which* logs to collect. We will do this via the command line.
   - Open an **administrative PowerShell or Command Prompt**.
   - Navigate to the UF's binary directory:
     ```powershell
     cd "C:\Program Files\SplunkUniversalForwarder\bin"
     ```
   - Add the Sysmon event log as a data input. We'll tag it with the index `botsv3` (a common practice from Splunk's "Boss of the SOC" competition) and a sourcetype of `XmlWinEventLog:Microsoft-Windows-Sysmon/Operational`.
     ```powershell
     .\splunk.exe add monitor "Microsoft-Windows-Sysmon/Operational" -index botsv3 -sourcetype "XmlWinEventLog:Microsoft-Windows-Sysmon/Operational"
     ```
   - Restart the forwarder for the changes to take effect:
     ```powershell
     .\splunk.exe restart
     ```

![Image: Configuring the Splunk UF via command line](images/uf-config-command.png)

---

## Phase 5: Data Ingestion & Verification

With everything configured, data should now be flowing from the victim machine to the SIEM. Let's verify it.

**1. Search for Data in Splunk:**
   - Go back to your Splunk web UI on the Windows Server VM.
   - Click on the **Search & Reporting** app.
   - In the search bar, enter the following SPL query to look for data in the index we specified:
     ```spl
     index="botsv3"
     ```
   - You should see events from your Windows 10 machine appearing. If you don't see data immediately, give it a few minutes. You can also expand the time-picker in the top right to "All time".

![Image: Verifying Sysmon data is arriving in Splunk](images/splunk-data-verification.png)

**Troubleshooting:** If you don't see any data:
-  Ensure both VMs can ping each other.
-  Verify the Windows Firewalls are off (or have rules for ports 9997 and 8089).
-  Double-check the IP addresses in your UF configuration.
-  Check the forwarder's internal logs for errors (`C:\Program Files\SplunkUniversalForwarder\var\log\splunk\splunkd.log`).

---

## Phase 6: Threat Simulation & Detection

This is where the lab comes to life. We will simulate a common attack technique and then write a Splunk query to detect it.

**1. The Scenario: PowerShell Download Cradle**
   - We will simulate an attacker using PowerShell to download and execute a script from the internet. This is a very common technique (MITRE ATT&CK T1059.001) used in initial access and execution stages of an attack.
   - We will use **Atomic Red Team** to perform this simulation safely.

**2. Install Atomic Red Team:**
   - On the Windows 10 "Victim" VM, open an **administrative PowerShell** window.
   - Run the following command to install the module:
     ```powershell
     Install-Module -Name AtomicRedTeam -Force
     Import-Module AtomicRedTeam
     ```

**3. Execute the Test:**
   - We will run the test for technique **T1059.001**. This specific test uses `IEX` (Invoke-Expression) to run a command, which is a classic indicator of malicious PowerShell activity.
   - In the same PowerShell window, run this command:
     ```powershell
     Invoke-AtomicTest T1059.001 -TestNumbers 3
     ```
   - This command will execute a harmless `IEX (New-Object Net.WebClient).DownloadString(...)` command.

![Image: Executing an Atomic Red Team test](images/atomic-red-team-execution.png)

**4. Detection with Splunk:**
   - Now, we pivot back to our SIEM to hunt for evidence of this activity.
   - Sysmon `EventCode=1` logs all process creations, including the command line used. We can search for the tell-tale `IEX` string within these command lines.
   - In Splunk Search, run the following query:
     ```spl
     index="botsv3" source="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=1 CommandLine="*IEX*"
     ```
   
   **Breaking Down the Query:**
   - `index="botsv3"`: Searches only in our specified index.
   - `source="...Sysmon/Operational"`: Filters for logs coming only from Sysmon.
   - `EventCode=1`: Filters for "Process Creation" events.
   - `CommandLine="*IEX*"`: This is the core of our detection. It searches the `CommandLine` field for the string "IEX". The asterisks `*` are wildcards, meaning it will match if "IEX" appears anywhere in the field.

**5. Analyze the Results:**
   - The search results should show the exact PowerShell command that was executed by Atomic Red Team. We can see the parent process (`powershell.exe`), the full command line, and other metadata. We have successfully detected the simulated threat!

![Image: Splunk search results showing the detected malicious command](images/splunk-detection-result.png)

---

## Conclusion & Future Improvements

This project successfully demonstrates the end-to-end process of setting up a security monitoring environment. We deployed a SIEM, configured endpoint logging, established a data pipeline, and used our setup to detect a simulated threat.

**Key Skills Demonstrated:**
-   Systems Administration (VMs, Networking, Windows Server)
-   SIEM Deployment & Management (Splunk)
-   Endpoint Security Monitoring (Sysmon)
-   Log Analysis & Detection Engineering (SPL)
-   Threat Emulation (Atomic Red Team)
-   Familiarity with the MITRE ATT&CK Framework

**Future Improvements for This Lab:**
-   **Create Alerts:** Turn the detection query into a Splunk Alert that would automatically notify an analyst.
-   **Build Dashboards:** Visualize the data with dashboards to track key security metrics (e.g., top running processes, network connections).
-   **Ingest More Log Sources:** Forward other Windows Event Logs (e.g., Security, System, PowerShell logs) to gain even more visibility.
-   **Test More ATT&CK Techniques:** Run more complex tests from Atomic Red Team and develop corresponding detection queries.
-   **Integrate a SOAR:** Add a Security Orchestration, Automation, and Response (SOAR) platform like Splunk SOAR to automate responses to alerts.
