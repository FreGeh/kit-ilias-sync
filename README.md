# pferd_sync for Linux

Sync KIT ILIAS with [PFERD](https://github.com/Garmelon/PFERD) and upload the files to bwSync&Share using `rclone`.

## Setup

### 1. Create the server

Create a Linux instance and set up SSH access.

Expected structure:

```text
/home/ubuntu/
├── Nextcloud/
└── pferd/
```

Clone this repository into `/home/ubuntu/pferd`.

### 2. Install PFERD

Download the latest Linux executable:

```bash
wget https://github.com/Garmelon/PFERD/releases/latest/download/pferd-linux
chmod +x pferd-linux
chmod +x syncing.sh
```

### 3. Configure PFERD credentials

Create the local credentials file:

```bash
cp .pferd_pass.example .pferd_pass
nano .pferd_pass
chmod 600 .pferd_pass
```

`.pferd_pass` is ignored by Git.

### 4. Configure the semester

Set the current semester in `syncing.sh`:

```bash
SEMESTER="SS26"
```

Always make sure the matching PFERD config exists:

```text
config_SS26.ini
```

The config determines the ILIAS courses, folder names and other PFERD settings.

### 5. Configure rclone

Install `rclone` and create the bwSync&Share remote:

```bash
rclone config
```

Example configuration:

```text
name: bwsyncshare_pferd
type: webdav
url: https://bwsyncandshare.kit.edu/remote.php/dav/files/<YOUR_USER>/
vendor: nextcloud
user: <YOUR_USER>
pass: <YOUR_PASSWORD>
```

The script expects the remote to be named:

```text
bwsyncshare_pferd
```

Test it with:

```bash
rclone lsd bwsyncshare_pferd:
```

### 6. Test the sync

Run:

```bash
./syncing.sh
```

PFERD downloads the selected ILIAS content into:

```text
/home/ubuntu/Nextcloud/<SEMESTER>
```

`rclone` then uploads it to:

```text
bwsyncshare_pferd:KIT Sharing/<SEMESTER>
```

### 7. Run automatically

Open the crontab:

```bash
crontab -e
```

Run the sync every 15 minutes:

```cron
*/15 * * * * /home/ubuntu/pferd/syncing.sh
```

Check the log with:

```bash
tail -f /home/ubuntu/pferd/pferd.log
```

## Updating PFERD

Replace `pferd-linux` with the newest release:

```bash
wget -O pferd-linux https://github.com/Garmelon/PFERD/releases/latest/download/pferd-linux
chmod +x pferd-linux
```
