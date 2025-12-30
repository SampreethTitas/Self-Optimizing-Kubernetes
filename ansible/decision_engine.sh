#!/bin/bash

# ---------------- CONFIG ----------------
DEPLOYMENT="load-optimizer"
CPU_THRESHOLD=450   # millicores
NAMESPACE="default"

# ---------------- READ CPU ----------------
CPU_RAW=$(kubectl top pod -n $NAMESPACE | awk 'NR==2 {print $2}')

# Remove 'm'
CURRENT_CPU=${CPU_RAW%m}

echo "Current CPU usage: ${CURRENT_CPU}m"

# ---------------- DECISION ----------------
if [ "$CURRENT_CPU" -gt "$CPU_THRESHOLD" ]; then
    echo "CPU exceeds threshold. Vertical scaling required."
    ansible-playbook -i inventory.ini vertical-scale.yaml
else
    echo "CPU within safe limits. No action taken."
fi
sleep 60

NEW_CPU_RAW=$(kubectl top pod -n $NAMESPACE | awk 'NR==2 {print $2}')
NEW_CPU=${NEW_CPU_RAW%m}

echo "CPU after scaling: ${NEW_CPU}m"

if [ "$NEW_CPU" -gt "$CURRENT_CPU" ]; then
    echo "CPU did not improve. Initiating rollback."
    ansible-playbook -i inventory.ini rollback.yaml
else
    echo "Vertical scaling successful. No rollback needed."
fi

