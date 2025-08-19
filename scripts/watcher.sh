#!/bin/bash
set -e

CPU_THRESHOLD=80
MEM_THRESHOLD=80
PENDING_THRESHOLD=1

SCALE_SCRIPT="/home/ubuntu/k8s-infra-zone-deployer/scripts/scale_up.sh"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

check_node_usage() {
    local output
    output=$(kubectl top nodes --no-headers)
    while read -r node cpu_m cpu_pct mem_m mem_pct; do
        cpu_val=$(echo "$cpu_pct" | tr -d '%')
        mem_val=$(echo "$mem_pct" | tr -d '%')

        if [ "$cpu_val" -ge "$CPU_THRESHOLD" ] || [ "$mem_val" -ge "$MEM_THRESHOLD" ]; then
            log "[ALERT] Node $node is over threshold (CPU: ${cpu_val}%, MEM: ${mem_val}%)"
            return 1
        fi
    done <<< "$output"
    return 0
}

check_pending_pods() {
    local pending
    pending=$(kubectl get pods --all-namespaces --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l)
    log "[DEBUG] Pending pods count: $pending"
    if [ "$pending" -ge "$PENDING_THRESHOLD" ]; then
        log "[ALERT] $pending pods pending."
        return 1
    fi
    return 0
}

while true; do
    log "[DEBUG] Checking node usage and pending pods..."
    if ! check_node_usage || ! check_pending_pods; then
        log "[INFO] Scaling triggered..."
        (
          cd /home/ubuntu/k8s-infra-zone-deployer/ && ANSIBLE_HOST_KEY_CHECKING=False ./scripts/scale_up.sh
        )
        log "[INFO] Scaling done. Waiting before next check..."
        sleep 300
    else
        log "[DEBUG] No scaling needed."
    fi
    sleep 30
done