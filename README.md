# Splunk + Sysmon SIEM Detection Project

## Introduction

This project is going to be the ground layer for a good homelab. At the time I'm writing this, my homelab environment will consist of one Windows 10 machine (as the target machine), one Server 2022 machine (as the Active Directory Domain Controller), one Kali Linux machine (as the attacking machine), and one Ubuntu Linux machine (as the Splunk server). All machines will be configured on the same network and subnet, but with different IPs.

This project is designed to provide a comprehensive homelab environment for cybersecurity enthusiasts, professionals, and students. The lab includes multiple virtual machines with varying operating systems, each serving distinct roles within the security ecosystem. The primary goal is to simulate real-world scenarios where you can safely test tools, protocols, applications, commands, and techniques without the risk of breaking a production environment.

## Tools, Operating Systems, Frameworks, and Languages used:

- VirtualBox
- Windows 10
- Server 2022
- Kali Linux
- Ubuntu Linux (CLI version)
- Splunk
- Sysmon
- Atomic Red Team
- MITRE ATT&CK
- MITRE DeTT&CT
- Active Directory Users and Computers
- PowerShell
- Command Prompt

## Why This Project?
This project is an excellent addition to your portfolio because it demonstrates your ability to set up and manage a sophisticated security information and event management (SIEM) environment. Here's what makes it valuable:

* Hands-On Experience: By working with multiple VMs running different OSs (Windows 10, Server 2022, Kali Linux, Ubuntu Linux), you gain practical experience with the tools and techniques used in a real-world security operations center (SOC).

* Versatility: The project's scope covers various responsibilities you might encounter in the industry, such as configuring and managing SIEM tools like Splunk, using Sysmon for enhanced Windows logging, and leveraging open-source tools like Atomic Red Team for simulating attacks.

* Learning and Experimentation: The homelab setup is intentionally kept bare bones, allowing you to build and expand upon it. This flexibility enables you to test different tools and frameworks in a controlled environment. Additionally, it gives you the opportunity to document your findings, improve your reporting skills, and create knowledge-base articles, further enriching your technical writing abilities.

 ## Computer Requirements
- CPU: 64-bit architecture Intel or AMD
- NOTE: ARM macs (M1, M2, M3) are NOT recommended due to limitations in virtualization. If you have no other options, please use the cloud to get the most out of this course.
- OS: Windows
- RAM: 16 GB or more
- Disk: 250 GB or more
- NOTE: if you do not meet these requirements, you can still do the labs, however, you may experience technical difficulties when it comes to the projects. Please consider using the cloud to complete the projects.

## Software Requirements
- Hypervisor: Any (Although VMWare Workstation Pro is recommended)
- NOTE: Any hypervisor should work, but I do provide a custom built Virtual Machine that will only work with VMWare. This custom Virtual Machine is not required but it is nice to have.
- Archive: 7-Zip

## Architecture Diagram
![Screenshot 2024-07-12 231512](https://github.com/user-attachments/assets/8ab64ff5-f94d-4c6d-ac8d-b9e1b319be51)

The architecture diagram above illustrates the setup for the Splunk + Sysmon Detection Project. The environment is built within the d3vhackz domain, which operates on the 192.168.10.0/24 network. The components involved in this project are interconnected as follows:

- Active Directory Server (192.168.10.7):
  - This server manages the domain d3vhackz.
  - It has both the Splunk Universal Forwarder and Sysmon installed to monitor and forward event logs to the Splunk Server for analysis.

- Splunk Server (192.168.10.10):
  - Acts as the central logging and analysis platform.
  - It collects logs from the Active Directory Server and the Windows 10 machine, allowing you to perform real-time searches, set alerts, and visualize data from various security events.

- Windows 10 Machine (Dynamic IP via DHCP):
  - Equipped with Sysmon, the Splunk Universal Forwarder, and Atomic Red Team tools.
  - This machine simulates an endpoint in the environment, providing logs to Splunk based on the simulated attacks from the Atomic Red Team.

- Kali Linux Machine (192.168.10.250):
  - Used as an attacker machine within the network.
  - It generates attack traffic that targets the Windows 10 machine and the Active Directory Server, simulating various cyber threats for detection and analysis in Splunk.

- Network Infrastructure:
  - The machines are connected within the 192.168.10.0/24 network, ensuring all components can communicate seamlessly.
  - Logs from Sysmon on both the Active Directory Server and Windows 10 machine are forwarded to the Splunk Server for centralized analysis.

This setup allows you to simulate and detect various attack techniques using a real-world-like environment. By using Sysmon and the Splunk Universal Forwarder, the system continuously monitors and forwards detailed logs to Splunk, where they can be analyzed against attack frameworks like MITRE ATT&CK.

## Usage Examples
Here are some ways you can use this project:

- Detecting Malicious PowerShell Execution
  - After simulating an attack using Atomic Red Team, you can query Splunk with:

```index=main sourcetype=XmlWinEventLog:Microsoft-Windows-Sysmon/Operational EventCode=1 Image="*powershell.exe"```

  - This will return logs where PowerShell was executed, allowing you to see potential malicious activity.

- Mapping Detections to MITRE ATT&CK
  - Once detections are logged in Splunk, you can map these events to MITRE ATT&CK techniques:

```| inputlookup attack_techniques.csv | search event_id=1```

 - This helps to identify which specific techniques were used during the attack.

- Simulating and Detecting Credential Dumping
 - Using the Invoke-Mimikatz command in Kali Linux, you can simulate credential dumping:
```Invoke-Mimikatz -DumpCred```

 - Query Splunk for Sysmon Event ID 10:

```index=main sourcetype=XmlWinEventLog:Microsoft-Windows-Sysmon/Operational EventCode=10```

 - This will show any instances where Mimikatz was detected attempting to dump credentials.
