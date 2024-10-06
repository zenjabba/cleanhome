#!/bin/bash

# Get the logical volume paths for root and home directories
ROOT_LV=$(lvdisplay | grep -B1 "/root" | grep "LV Path" | awk '{print $3}')
HOME_LV=$(lvdisplay | grep -B1 "/home" | grep "LV Path" | awk '{print $3}')

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Stop the ceph.target service
systemctl stop ceph.target

# Wait for all running podman containers to stop
while [ -n "$(podman ps -a --filter "status=running" -q)" ]; do
    echo "Waiting for all podman containers to completely stop..."
    sleep 1
done

echo "All podman containers have been stopped, continuing..."

# Backup the /home directory to ~/root-home
echo "Backing up /home directory to ~/root-home..."
cp -rp /home ~/root-home

# Unmount the /home directory forcefully and lazily
echo "Unmounting /home directory..."
umount -fl /home

# Remove the logical volume associated with /home
echo "Removing logical volume for /home..."
while ! lvremove -y "$HOME_LV"; do
    echo "Waiting for logical volume to be removed..."
    sleep 1
done

# Extend the root logical volume to use all available free space
echo "Extending root logical volume to use all available free space..."
lvextend -l +100%FREE "$ROOT_LV"

# Grow the filesystem on the root logical volume to use the newly allocated space
echo "Growing filesystem on root logical volume..."
xfs_growfs "$ROOT_LV"

# Move the backup of /home back to /home
echo "Moving backup of /home back to /home..."
mv ~/root-home /home

# Move the contents of the backup directory to /home
echo "Moving contents of backup directory to /home..."
mv /home/root-home/* /home/

# Remove the temporary backup directory
echo "Removing temporary backup directory..."
rm -rf /home/root-home

# Restart the ceph.target service
echo "Restarting ceph.target service..."
systemctl start ceph.target
