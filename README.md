Sync ILIAS with [PFERD](https://github.com/Garmelon/PFERD) and upload the files to bwSync&Share using `rclone`.

## Setup

### 1. Create the server

Create an Ubuntu server and set up SSH access.

A free, good option is [bwCloud](https://api.ka.bwcos.de/home/).

Install the required packages:

```bash
sudo apt update
sudo apt install -y git wget rclone
```

Clone the repository into `/home/ubuntu/pferd`:

```bash
cd ~
git clone https://github.com/FreGeh/kit-ilias-sync pferd
cd pferd
```

Expected structure:

```text
/home/ubuntu/
├── Nextcloud/
└── pferd/
```

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

Fill in the two existing lines with your ILIAS credentials.

*`.pferd_pass` is ignored by Git and should never be committed*

### 4. Configure the semester

Set the current semester in `syncing.sh`:

```bash
SEMESTER="SS26"
```

Make sure the matching config exists:

```text
config_SS26.ini
```

The config contains the PFERD settings and course rename rules for that semester.

### 5. Configure rclone

Create a WebDAV remote:

```bash
rclone config
```

First create a new **app password** in [bwSync&Share Security Settings](https://bwsyncandshare.kit.edu/settings/user/security), to then set it up like this:

```text
name: bwsyncshare_pferd
type: webdav
url: https://bwsyncandshare.kit.edu/remote.php/dav/files/<APP_USERNAME>/
vendor: nextcloud
user: <APP_USERNAME>
pass: <APP_PASSWORD>
```

Do not use the normal KIT password here. Use the generated bwSync&Share app credentials.

The remote must be named:

```text
bwsyncshare_pferd
```

Test it:

```bash
rclone lsd bwsyncshare_pferd:
```

It should list your bwSync&Share folders.

### 6. Test the sync

Run the script manually first:

```bash
./syncing.sh
```

PFERD downloads into:

```text
/home/ubuntu/Nextcloud/<SEMESTER>
```

`rclone` then uploads to:

```text
bwsyncshare_pferd:KIT Sharing/<SEMESTER>
```

Check the log if something fails:

```bash
tail -n 100 pferd.log
```

### 7. Run automatically

```bash
crontab -e
```

For example every 15 minutes:

```cron
*/15 * * * * /home/ubuntu/pferd/syncing.sh
```

Check:

```bash
crontab -l
```

Follow the sync log:

```bash
tail -f /home/ubuntu/pferd/pferd.log
```

## Updating PFERD

Replace `pferd-linux` with the newest release:

```bash
cd /home/ubuntu/pferd
wget -O pferd-linux https://github.com/Garmelon/PFERD/releases/latest/download/pferd-linux
chmod +x pferd-linux
```
