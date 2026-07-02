# cyberbot-maintenance: Out-of-Memory Issue Resolution

## 1. Summary

We have completed the setup of automated maintenance scripts for the server hosting Cyberbot.

The purpose of this setup is to help the server automatically handle routine maintenance tasks, including disk cleanup and cleanup of stale Chrome processes. The scripts were created, tested, and scheduled to run automatically through cron jobs.

The maintenance setup includes two main scripts:

* `kill_stale_chrome.sh`
* `cleanup_disk.sh`

Both scripts are stored under:

```bash
/opt/cyber_bot/maintenance
```

Execution logs are stored under:

```bash
/var/log/cyber_bot/maintenance
```

---

## 2. Current Issues

The server hosting Cyberbot has been running out of memory and has experienced downtime recently.

Based on the initial review, stale Chrome processes may be contributing to the high memory usage. These processes can remain active for a long time with low CPU usage while still consuming memory and server resources.

To reduce the risk of recurring downtime, automated maintenance scripts were implemented to clean up stale Chrome processes and perform routine system cleanup.

---

## 3. Solution

Two maintenance scripts were created and configured.

### 3.1 Disk Cleanup Script

The disk cleanup script performs routine cleanup actions to remove unnecessary files and reduce disk usage where possible.

The script performs the following actions:

* Cleans temporary files under `/tmp`.
* Removes disabled snap revisions.
* Vacuums old journal logs.
* Cleans the apt cache.
* Records disk usage before and after cleanup for easier review.

### 3.2 Stale Chrome Process Cleanup Script

The Chrome maintenance script was created to detect and handle stale Chrome processes.

The script checks Chrome processes based on the following conditions:

* Runtime greater than `120` minutes.
* CPU usage lower than `1%`.

If a process matches these conditions, it will be treated as stale and handled by the script.

### 3.3 Cron Job Setup

Cron jobs were configured to run the maintenance scripts automatically on separate schedules based on their purpose.

The current cron configuration is:

```cron
*/30 * * * * /opt/cyber_bot/maintenance/kill_stale_chrome.sh >> /var/log/cyber_bot/maintenance/kill_stale_chrome.log 2>&1

0 3 * * * /opt/cyber_bot/maintenance/cleanup_disk.sh >> /var/log/cyber_bot/maintenance/cleanup_disk.log 2>&1
```

This means:

* `kill_stale_chrome.sh` runs every 30 minutes.
* `cleanup_disk.sh` runs once per day at `03:00 UTC`.

Logs can be reviewed using:

```bash
sudo tail -100 /var/log/cyber_bot/maintenance/kill_stale_chrome.log
```

```bash
sudo tail -100 /var/log/cyber_bot/maintenance/cleanup_disk.log
```

---

## 4. Benefits

This setup provides the following benefits:

* Reduces the need for manual server maintenance.
* Helps prevent stale Chrome processes from consuming server resources for extended periods.
* Provides automatic disk cleanup for temporary files, old snap revisions, journal logs, and apt cache.
* Improves visibility through before/after cleanup logs.
* Makes it easier to review maintenance results and confirm whether cleanup actions are effective.
* Provides a reusable maintenance structure, making it easier to trigger, monitor, or extend in the future.

Overall, the automation helps keep the server more stable and easier to maintain, while also giving the team better visibility into maintenance activity.
