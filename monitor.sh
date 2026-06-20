#!/bin/bash

# === Incident Response Automation Script ===
# Detects SSH brute-force attacks, suspicious sudo activity,
# abnormal network activity, collects evidence, and blocks attacker IPs.

LOG_DIR="logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SSH_LOG="$LOG_DIR/${TIMESTAMP}_ssh"
SUDO_LOG="$LOG_DIR/${TIMESTAMP}_sudo"
NET_LOG="$LOG_DIR/${TIMESTAMP}_network"

echo "[sudo] password for $USER:"
sudo -v

echo "Checking for SSH brute-force attempts..."
FAILED_SSH=$(sudo journalctl -u ssh --since "10 minutes ago" | grep "Failed password" | wc -l)

if [ "$FAILED_SSH" -ge 5 ]; then
    echo "[$(date)] ALERT: Possible SSH brute-force attack detected."
    echo "Failed SSH attempts: $FAILED_SSH"
    echo "Collecting SSH-related evidence..."
    sudo journalctl -u ssh --since "10 minutes ago" > "$SSH_LOG"
    echo "Evidence saved to $SSH_LOG"
else
    echo "No SSH brute-force detected."
fi

echo "Checking for suspicious sudo activity..."
SUDO_FAIL=$(sudo journalctl -u sudo --since "10 minutes ago" | grep "authentication failure" | wc -l)

if [ "$SUDO_FAIL" -ge 3 ]; then
    echo "[$(date)] ALERT: Suspicious sudo activity detected."
    sudo journalctl -u sudo --since "10 minutes ago" > "$SUDO_LOG"
    echo "Evidence saved to $SUDO_LOG"
else
    echo "No suspicious sudo activity detected."
fi

echo "Checking for suspicious network activity..."
NETSTAT=$(netstat -ant | grep SYN_RECV | wc -l)

if [ "$NETSTAT" -ge 20 ]; then
    echo "[$(date)] ALERT: Possible network scan detected."
    netstat -ant | grep SYN_RECV > "$NET_LOG"
    echo "Evidence saved to $NET_LOG"
else
    echo "No suspicious network activity detected."
fi

echo "Checking for attacker IPs to block..."
ATTACKER_IPS=$(sudo journalctl -u ssh --since "10 minutes ago" | grep "Failed password" | awk '{print $(NF-3)}' | sort -u)

if [ -n "$ATTACKER_IPS" ]; then
    echo "Attacker IPs detected:"
    echo "$ATTACKER_IPS"
    for ip in $ATTACKER_IPS; do
        echo "Blocking IP: $ip"
        sudo iptables -A INPUT -s "$ip" -j DROP
    done
    echo "IP blocking complete."
else
    echo "No attacker IPs found."
fi
