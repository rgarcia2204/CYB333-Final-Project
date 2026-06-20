# CYB333-Final-Project
Clone the repository: git clone [https://github.com/rgarcia2204/incident-response-automation cd incident-response-automation](https://github.com/rgarcia2204/CYB333-Final-Project/blob/main/monitor.sh)
Make the script executable: chmod +x monitor.sh
Run the script: ./monitor.sh
Evidence will be saved automatically in the logs/ directory.

Requirements
Linux system (Kali recommended)
systemd with journalctl
iptables
net-tools (for netstat)
SSH service enabled (sshd)

To generate detectable events, you can intentionally fail SSH login attempts:
ssh kali@<your-ip>

Enter the wrong password several times to trigger the brute‑force detection logic. The script will then:
Detect the failed attempts
Save evidence
Identify the attacker IP
Block the IP

Project Structure
incident-response-automation/
│
├── monitor.sh
├── reset-firewall.sh   (optional)
├── logs/               (auto-generated)
└── README.md

![Detection](screenshots/01_detection_and_response.png)
![Evidence](screenshots/02_evidence_collection.png)
![IP Blocked](screenshots/03_ip_blocked.png)
