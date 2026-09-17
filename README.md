# PharmaCare POS - Compiled Production Release

This repository contains the **compiled, standalone distribution package** of PharmaCare POS & Pharmacy Management System.

---

## ?? 1-Click Installation (For Client Pharmacies)

1. Download or clone this folder into C:\PharmaCare.
2. Right-click **`1-CLICK-SETUP.bat`** and choose **"Run as Administrator"**.
3. Open your browser at **[http://pharmacy.local](http://pharmacy.local)** or **[http://localhost:3000](http://localhost:3000)**.

---

## ?? Updating to Latest Release

Admins can update with **1 click directly inside the web application**:
1. Log in to **PharmaCare POS**.
2. Go to **Settings** -> **Software Updates & Sync**.
3. Click **"Check for Updates"** -> **"Update & Sync Now"**.
4. The system updates and reloads in **3 seconds** without compiling or touching any terminal.

---

## ?? Service Management

To start/stop manually:
`cmd
pm2 start ecosystem.config.js
pm2 stop all
pm2 restart all
`
"@

 = @"
# Local machine specific
.env.local
.env.development.local
*.log
