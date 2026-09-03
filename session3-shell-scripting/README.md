Shell scripting homework. Script file is system_info.sh in this folder.

The script prints the current date, hostname, username, disk usage, and running processes. It uses variables, read -p for input, mkdir to create a directory, touch to create a file, and redirects ps output into that file with >.

How to run:
chmod +x system_info.sh
./system_info.sh

Command output from a run on minty@homelab (Thu Sep 3 2026):

===== System Information =====
Date:       Thu Sep  3 05:47:01 PM IST 2026
Hostname:   homelab
Username:   minty

===== Disk Usage =====
Filesystem                         Size  Used Avail Use% Mounted on
tmpfs                              2.2G  4.2M  2.2G   1% /run
/dev/mapper/ubuntu--vg-ubuntu--lv  290G  110G  168G  40% /
tmpfs                              5.5G     0  5.5G   0% /dev/shm
efivarfs                           182K  112K   66K  64% /sys/firmware/efi/efivars
tmpfs                              5.5G  2.1G  3.5G  37% /tmp
/dev/sdb2                          466G  3.9G  462G   1% /mnt/backups
/dev/sda2                          2.0G  184M  1.7G  11% /boot
/dev/sda1                          1.1G  6.4M  1.1G   1% /boot/efi
tmpfs                              1.1G  8.0K  1.1G   1% /run/user/1000

===== Running Processes =====
    PID TTY          TIME CMD
   6658 ?        00:51:26 uvicorn
   7082 ?        00:10:19 mcmanager
   7331 ?        00:00:01 python
2918518 ?        00:00:01 systemd
2918520 ?        00:00:00 (sd-pam)
3198931 ?        00:00:00 sshd-session
3198932 ?        00:00:00 bash
3198937 ?        00:00:00 system_info.sh
3198942 ?        00:00:00 ps

Enter your name: Chandan
Enter a directory name to create: sysinfo_output
Enter a file name to store process info: process.log

Hello, Chandan.
Created directory: sysinfo_output
Created file:      sysinfo_output/process.log
Running processes were written to sysinfo_output/process.log

===== File contents (sysinfo_output/process.log) =====
    PID TTY          TIME CMD
   6658 ?        00:51:26 uvicorn
   7082 ?        00:10:19 mcmanager
   7331 ?        00:00:01 python
2918518 ?        00:00:01 systemd
2918520 ?        00:00:00 (sd-pam)
3198931 ?        00:00:00 sshd-session
3198932 ?        00:00:00 bash
3198937 ?        00:00:00 system_info.sh
3198945 ?        00:00:00 ps

Public repo: https://github.com/NoiceHax/devops-heros
