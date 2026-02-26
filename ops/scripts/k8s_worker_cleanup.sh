#!/bin/bash
set -euo pipefail

echo "🧹 Kubernetes Worker Node Cleanup Started"

# 1. Stop services
echo "⛔ Stopping kubelet and container runtime..."
systemctl stop kubelet || true
systemctl stop containerd || true
systemctl stop docker || true

# 2. Kill any leftover kubelet processes
echo "🔪 Killing leftover kubelet processes..."
pkill -9 kubelet || true

# 3. Unmount kubelet mounts (THIS fixes your 'device busy' issue)
echo "📦 Unmounting kubelet mounts..."
mount | grep '/var/lib/kubelet' | awk '{print $3}' | sort -r | xargs -r umount -lf

# 4. Reset kubeadm (safe even if already reset)
echo "♻️ Running kubeadm reset..."
kubeadm reset -f || true

# 5. Remove Kubernetes directories
echo "🗑 Removing Kubernetes directories..."
rm -rfv \
/etc/kubernetes \
/var/lib/kubelet \
/var/lib/etcd \
/etc/cni \
/opt/cni \
/var/lib/cni

# 6. Clean iptables
echo "🧽 Cleaning iptables..."
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# 7. Clean IPVS (if used)
if command -v ipvsadm &>/dev/null; then
    echo "🧼 Clearing IPVS tables..."
    ipvsadm --clear
    fi

    # 8. Restart container runtime
    echo "🔄 Restarting container runtime..."
    systemctl start containerd || true
    systemctl start docker || true

    # 9. Disable kubelet (worker is not part of cluster anymore)
    echo "🚫 Disabling kubelet..."
    systemctl disable kubelet || true

    echo "✅ Worker node cleanup completed successfully!"
    echo "➡️ You can now safely re-join this node using kubeadm join"

