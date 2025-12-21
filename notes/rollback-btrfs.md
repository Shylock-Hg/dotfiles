To perform a rollback using **Btrfs** manually (without relying on higher-level tools like Snapper or Timeshift), you essentially need to replace the current, problematic root filesystem subvolume (`@`) with a known good snapshot.

This method is the most robust way to recover your system from a Linux Live USB, especially when the `snapper` service is throwing D-Bus errors inside a chroot.

Here is the step-by-step process.

-----

## 1\. 🔍 Prerequisites: Mount the Btrfs Partition

You must boot into a Live Linux environment (like a CachyOS, openSUSE, or Arch USB stick) and mount the top level of your installed system's Btrfs partition.

1.  **Identify the Btrfs Partition:**
    Use `lsblk -f` to find the device name of your main Btrfs partition (e.g., `/dev/sdXY`).

2.  **Mount the Top-Level Volume:**
    Mount the partition using the default subvolume ID (`subvolid=5`) to a temporary location like `/mnt`. This allows you to see all the subvolumes and the `.snapshots` directory.

    ```bash
    sudo mkdir -p /mnt
    # Mount the top-level (subvolid=5) of the Btrfs filesystem (the partiton of root btrfs file system)
    sudo mount -o subvolid=5 /dev/sdXY /mnt
    ```

3.  **Identify Subvolumes and Snapshot ID:**
    List the contents of the mount point to find your root subvolume (usually named **`@`**) and the target snapshot within the `.snapshots` directory.

    ```bash
    sudo btrfs subvolume list /mnt
    # Example: Look for .snapshots/@mnt/snapshots/X/snapshot
    ```

    Assume you found a good snapshot at path `/mnt/.snapshots/57/snapshot`.

-----

## 2\. 🔄 Perform the Manual Btrfs Rollback

This process involves renaming the broken subvolume and creating a read-write snapshot of the good state, naming the new copy as the default root (`@`).

### A. Rename the Broken Root

Rename the current, corrupted or problematic root subvolume (`@`) to safely archive it.

```bash
# Rename the current root subvolume to avoid conflict
sudo mv /mnt/@ /mnt/@.broken
```

### B. Create the New Root Subvolume

Use the `btrfs subvolume snapshot` command to create a **read-write** copy of your chosen good snapshot (e.g., ID 57) and assign it the name `@`.

```bash
# Snapshot the good backup (read-only) and assign the name '@' to the new read-write copy
sudo btrfs subvolume snapshot /mnt/@.broken/.snapshots/57/snapshot /mnt/@
```

**Explanation:** This command instantly creates the new root filesystem (`/mnt/@`) in the exact state of the snapshot.

-----

## 3\. 📝 Update Boot Configuration

Since you replaced the root filesystem, you must ensure the kernel and bootloader are using the correct file paths.

1.  **Chroot into the Restored System:**

    ```bash
    # Mount virtual filesystems first
    sudo mount -o bind /dev /mnt/@/dev
    sudo mount -t proc none /mnt/@/proc
    sudo mount -t sysfs none /mnt/@/sys
    # Enter the restored system
    sudo chroot /mnt/@
    ```

2.  **Regenerate Initramfs:**
    This ensures the restored kernel modules are correctly packaged.

    ```bash
    mkinitcpio -P
    ```

3.  **Update Bootloader (If using Grub, not for EFI):**
    If your system uses GRUB, update its configuration file.

    ```bash
    grub-mkconfig -o /boot/grub/grub.cfg
    ```

4.  **Exit and Reboot:**

    ```bash
    exit
    sudo umount -R /mnt
    reboot
    ```

Your system should now boot into the restored snapshot. You can manually delete the `@_broken_...` subvolume later once you confirm the restoration was successful.
