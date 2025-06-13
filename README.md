# My Splunk + Sysmon Detection Lab

This repository contains all the configurations and documentation for a comprehensive security information and event management (SIEM) lab I built. The environment is centered around a full Microsoft Active Directory domain, enabling the simulation and detection of realistic adversary techniques.

This project is documented to serve as a portfolio piece and a detailed blueprint for anyone looking to build their own hands-on detection lab.

<p align="center">
  <img src="docs/assets/lab-architecture.png" alt="Lab Architecture Diagram" width="800"/>
</p>

## Project Goals

*   **Enterprise Environment Simulation:** To build and configure a multi-server environment with Active Directory, replicating a typical corporate network.
*   **End-to-End Log Collection:** To instrument Windows endpoints with Sysmon and configure Splunk forwarders to centralize security, application, and system logs in Splunk.
*   **Threat Simulation:** To use industry-standard frameworks like **Atomic Red Team** and adversary tools like `crowbar` to execute controlled attacks mapped to the **MITRE ATT&CK** framework.
*   **Detection Engineering:** To analyze the generated logs, identify indicators of compromise (IOCs), and build high-fidelity Splunk queries to detect malicious activity.

## ✨ Features & Technologies Used

*   **SIEM:** Splunk Enterprise 9.2
*   **Directory Service:** Microsoft Active Directory
*   **Endpoint Logging:** Microsoft Sysmon with a modular configuration
*   **Log Forwarding:** Splunk Universal Forwarder
*   **Attack Simulation:** Atomic Red Team, Crowbar (RDP Brute-Forcer)
*   **Virtualization:** Oracle VirtualBox
*   **Operating Systems:** Windows Server 2022, Windows 10, Ubuntu Server, Kali Linux

---

## 🚀 Full Illustrated Guide

I have written a complete, illustrated step-by-step guide that walks through the entire lab creation process—from setting up the virtual machines and Active Directory to executing and detecting the final attacks.

### **[➡️ View the Full Tutorial Here](./docs/TUTORIAL.md)**

---

## 🎯 Example Detections Showcase

Here is a quick look at some of the threats this lab can detect. The full tutorial details how to perform the attacks and build the detection logic.

| MITRE ATT&CK Tactic | Technique (ID)                                | Detection Logic in Splunk                                                                |
| ------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **Persistence**     | Create Account: Local Account (T1136.001)     | `index=endpoint EventCode=4720`                                                          |
| **Credential Access** | Brute Force: Password Spraying (T1110.003)    | `index=endpoint EventCode=4625` with a high count of failures from a single source IP    |

## 📁 Repository Contents

*   **/docs/**: Contains the full, illustrated step-by-step tutorial and all image assets.
*   **/configs/**: Contains the configuration files needed for the Splunk Universal Forwarder.
*   `README.md`: This file, providing a high-level overview of the project.