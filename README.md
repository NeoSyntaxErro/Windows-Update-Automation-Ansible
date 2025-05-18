# 🛠️ Windows Patch Management Playbook

This Ansible playbook is designed to automate routine patch management on Windows 10/11 endpoints. It performs the following:

- ✅ Installs or updates third-party applications via **Chocolatey**.
- 🔄 Checks for and installs **Windows OS updates** using `PSWindowsUpdate`.
- 📦 Ensures required PowerShell modules (e.g., `NuGet`, `PSWindowsUpdate`) are present.
- ♻️ Reboots endpoints when required after patching.
- 📝 Outputs update logs for auditing and troubleshooting.

---

## ⚙️ Prerequisites & Inventory Setup

Each Windows endpoint must meet the following requirements:

- A local **administrator account** (e.g., `AnsibleAdmin`) must be available.
- Each system must have **OpenSSH** or an equivalent SSH server installed and enabled.
- You must configure **WinRM** to support elevated command execution.

---

### 🧾 Sample Inventory File

Update your `inventory.ini` file with the hosts and variables required for both SSH and WinRM connection methods:

```ini
[endpoints_winrm]
HOST1.lan
HOST2.lan
HOST3.lan

[endpoints_ssh]
HOST1.lan
HOST2.lan
HOST3.lan

[endpoints_conf]
HOST1.lan
HOST2.lan
HOST3.lan

[endpoints_winrm:vars]
ansible_user=AnsibleAdmin
ansible_password=REPLACE_ME
ansible_connection=winrm
ansible_port=5985
ansible_winrm_transport=basic
ansible_winrm_server_cert_validation=ignore

[endpoints_ssh:vars]
ansible_user=AnsibleAdmin
ansible_password=REPLACE_ME
ansible_connection=ssh
ansible_shell_type=powershell
ansible_shell_executable=powershell.exe

[endpoints_conf:vars]
ansible_user=AnsibleAdmin
ansible_password=REPLACE_ME
ansible_connection=ssh
ansible_shell_type=cmd
ansible_shell_executable=cmd.exe
```

> **Note:** The playbook uses different shell types and connection methods to support initial setup, configuration, and patching steps. The `endpoints_conf` group is used to prepare hosts for both SSH and WinRM access.

---

## 🛠️ Running the Configuration Playbook

Once your inventory is set up, run the configuration playbook to prepare your Windows endpoints for patching:

```bash
ansible-playbook ConfigureEndpoints.yml -i /path/to/inventory.ini
```

This step will:

- Set PowerShell as the default shell for OpenSSH.
- Enable and configure WinRM.
- Open firewall ports for WinRM communication.
- Ensure your Ansible user is properly authorized.

---

## ⏱️ Automated Execution via Shell Script

To simplify scheduling, use the provided helper shell script: `run_patch_playbook.sh`.

### 📌 What the Script Does

- Accepts two arguments: the path to the Ansible playbook and the inventory file.
- Validates that the files exist.
- Sets up a **cron job** to run the playbook **every Sunday at 11:30 PM**.
- Logs playbook output to: `~/ansible-patch-logs/patch_run.log`

### 💻 Example Usage

```bash
chmod +x run_patch_playbook.sh
./run_patch_playbook.sh /path/to/playbook.yml /path/to/inventory.ini
```

> This script is optional and meant to expedite automation. You can manually add the cron job if preferred.

---

## 🧪 Logging and Troubleshooting

- Playbook output is automatically logged by the cron job.
- Windows patch logs (from `Install-WindowsUpdate`) are saved locally on the endpoint (e.g., `C:\temp\update_log.txt`).
- Ensure firewall rules, WinRM configuration, and the Ansible control machine's connectivity are verified if errors occur.

---

## 📢 Additional Notes

- Chocolatey is used to manage and update third-party software.
- WinRM is required for privilege escalation on endpoints during Windows Update.
- PowerShell is enforced over SSH to ensure proper execution of Windows modules.

---

Created and maintained by: **Steffen Teall**
