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


---
# ⚠️ Security Advisory: Use in Trusted Environments Only

This project is intended for use in secure, isolated environments such as test labs or internal networks. The default configurations, including WinRM over HTTP and potential use of basic authentication, expose sensitive data and credentials to interception risks. Deploying this setup in untrusted or production environments without modifications can lead to significant security vulnerabilities.

---

## 🔐 Recommendations for Securing WinRM and SSH Connections

### WinRM (Windows Remote Management)

- **Enable HTTPS**: Configure WinRM to use HTTPS with valid TLS certificates to encrypt data in transit. This prevents credentials and other sensitive information from being transmitted in plaintext.
- **Use Secure Authentication Methods**: Prefer Kerberos authentication in domain environments or certificate-based authentication for local accounts. Avoid using Basic or NTLM authentication over HTTP.
- **Restrict Access**: Limit WinRM access to specific IP addresses or networks using firewall rules to reduce exposure to potential attackers.

### SSH (Secure Shell)

- **Disable Password Authentication**: Configure SSH to accept only key-based authentication, eliminating the risks associated with password-based logins.
- **Use Non-Root Users**: Set up dedicated, unprivileged users for Ansible operations, granting necessary privileges via `sudo` as needed. This adheres to the principle of least privilege.
- **Implement SSH Hardening Measures**: Consider additional SSH hardening practices, such as changing the default SSH port, disabling root login, setting idle timeout intervals, and limiting the number of authentication attempts.

---

## 🛡️ General Security Best Practices

- **Encrypt Sensitive Data**: Use Ansible Vault to encrypt passwords, API keys, and other sensitive variables within your playbooks.
- **Implement Role-Based Access Control (RBAC)**: Utilize Ansible Tower or AWX to manage user permissions, ensuring that only authorized personnel can execute specific tasks.
- **Sanitize Output**: Use the `no_log: true` directive in tasks that handle sensitive information to prevent credentials from being displayed in logs.

---

By implementing these security measures, you can enhance the protection of your systems when using the Windows-Update-Automation-Ansible framework in more exposed or production environments.
