# Ceph Remove Home Script

This repository contains a Bash script designed to manage logical volumes by removing the `/home` logical volume, extending the `/root` logical volume, and then restoring the `/home` directory from a backup. This script is particularly useful for systems using Ceph and logical volume management.

## Prerequisites

- Ensure you have root privileges to execute the script.
- The system should have `lvdisplay`, `lvremove`, `lvextend`, `xfs_growfs`, and `systemctl` commands available.
- The script assumes the use of `podman` for container management.

## Usage

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
   ```

2. **Run the Script:**

   Execute the script with root privileges:

   ```bash
   sudo ./ceph-remove-home.sh
   ```

3. **Script Workflow:**

   - Stops the `ceph.target` service.
   - Waits for all running `podman` containers to stop.
   - Backs up the `/home` directory to `~/root-home`.
   - Unmounts and removes the `/home` logical volume.
   - Extends the `/root` logical volume to use all available free space.
   - Grows the filesystem on the `/root` logical volume.
   - Restores the `/home` directory from the backup.
   - Restarts the `ceph.target` service.

## Important Notes

- **Data Backup:** Ensure that you have a reliable backup of your data before running this script, as it involves removing and modifying logical volumes.
- **System Impact:** This script will stop the `ceph.target` service and all running `podman` containers, which may impact system operations.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.
