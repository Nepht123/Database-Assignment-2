# Clearpoint Database: Setup and Run Guide

**CSC312 Practical 2 · Power Rangers**

Follow these steps to build the Clearpoint database on your own laptop, check it matches everyone else's, and run the Python script. It takes about 30 minutes, and **you do not need to be on campus**: you install your own free MySQL server.

Do every step in order. Each step ends with a **✅ Check**; don't move on until it passes.

---

## What you'll end up with

- MySQL Server running on your laptop
- The `clearpoint` database with 9 tables and 183 rows, identical to everyone else's
- The Python script running all 10 report queries
- Screenshots and one constraint test for the report

---

## Step 1: Check whether MySQL Server is installed

MySQL **Workbench** is only the program you type SQL into. MySQL **Server** is the engine that stores the data, and you need both.

1. Press **Windows key + R**, type `services.msc` and press **Enter**.
2. Click any service in the list and press **M** to jump to the M's.
3. Look for a service starting with **MySQL** (e.g. `MySQL80`, `MySQL84`).

**✅ Check:** If you find one with Status **Running**, skip to **Step 4**. If not, do Steps 2 and 3.

---

## Step 2: Download and install MySQL Server

1. Go to **https://dev.mysql.com/downloads/mysql/**
2. **Select Version:** choose **8.4.11 LTS**. **Operating System:** **Microsoft Windows**.
3. On the row **Windows (x86, 64-bit), MSI Installer** (about 120 MB), click **Download**.
4. On the next page, click **"No thanks, just start my download."**
5. Open the `.msi` file → **Next** → accept the licence → **Typical** → **Install** → **Yes** to the admin prompt.
6. At the end, leave **"Run MySQL Configurator"** ticked and click **Finish**.

**✅ Check:** A window called **MySQL Configurator** opens.

---

## Step 3: Configure the server

Click **Next** through each screen, changing only what's listed here:

| Screen | What to do |
| --- | --- |
| Welcome | Next |
| Data Directory | Leave the default |
| Type and Networking | Config Type **Development Computer**; port **3306**; tick **Open Windows Firewall ports** |
| Accounts and Roles | Enter a **root password** twice: letters and numbers only. **Write it down.** No extra users needed |
| Windows Service | Leave everything ticked (service name like **MySQL84**, start at startup) |
| Server File Permissions | Leave the default |
| Sample Databases | Leave unticked |
| Apply Configuration | Click **Execute** and wait |

**✅ Check:** Every step in Apply Configuration shows a **green tick**. Then click **Next → Finish**.

---

## Step 4: Connect Workbench to your server

1. Open **MySQL Workbench**.
2. Click the **+** next to **MySQL Connections**.
3. Fill in:
   - **Connection Name:** `Clearpoint Local`
   - **Hostname:** `127.0.0.1`
   - **Port:** `3306`
   - **Username:** `root`
4. **Password → Store in Vault…**: enter your root password and click **OK**.
5. Click **Test Connection**. If it warns about an "incompatible/nonstandard server version", click **Continue Anyway**; this is harmless.
6. Click **OK**, then **double-click** the new **Clearpoint Local** tile.

**✅ Check:** "Successfully made the MySQL connection", and a tab opens with an empty SQL editor.

---

## Step 5: Get the project files

1. Go to **https://github.com/Nepht123/Database-Assignment-2**
2. Click the green **Code** button → **Download ZIP**.
3. In Downloads, right-click the ZIP → **Extract All…** → choose your **Documents** folder → **Extract**.

**✅ Check:** The folder contains `schema.sql`, `data.sql`, `verify.sql`, `queries.sql`, `reminders.sql`, `constraint_tests.sql`, `run_queries.py`, `config.example.ini` and `README.md`.

> If the SQL files are inside a `sql` folder on your copy, that's fine: open them from there in the steps below.

---

## Step 6: Create the database

1. In the Workbench editor, type:
   ```sql
   CREATE DATABASE clearpoint;
   USE clearpoint;
   SELECT DATABASE();
   ```
2. Click the **plain lightning bolt** (Execute). Don't use the one with the cursor icon.
3. In the **Navigator** (left), open the **Schemas** tab and click the **refresh** icon.
4. **Right-click `clearpoint` → Set as Default Schema.** It may or may not look bold; either is fine.

**✅ Check:** The result grid under `DATABASE()` shows **clearpoint**.

---

## Step 7: Create the tables and load the data

1. **File → Open SQL Script…** → `schema.sql` → click the **lightning bolt**.
   - Yellow ⚠ warnings on the `DROP TABLE IF EXISTS` lines are **normal** ("Unknown table").
2. **File → Open SQL Script…** → `data.sql` → click the **lightning bolt**.
   - You should see 9 green ticks saying "N row(s) affected".
3. In the Navigator, click **refresh**, then expand **clearpoint → Tables**.

**✅ Check:** You see **9 tables**: adviser, adviser_licence, claim, client, compliance_document, goal, policy, product, provider.

> **"Error Code: 1046. No database selected"?** Add `USE clearpoint;` as the first line of the file and run it again.
> **"Duplicate entry" errors?** You ran `data.sql` twice. Run `schema.sql` again, then `data.sql` once.

---

## Step 8: Verify your database matches everyone else's

1. **File → Open SQL Script…** → `verify.sql` → **lightning bolt**.
2. **Result 1:** every `row_count` must equal `expected`.
3. **Result 2** must show exactly:

| total_premium | total_claimed | open_claims |
| --- | --- | --- |
| 40418.00 | 548000.00 | 8 |

**✅ Check:** All numbers match. **Post a screenshot of Result 2 in the group chat** so we know all six databases are identical.

---

## Step 9: Install Python and the MySQL connector

1. Press the **Windows key**, type `cmd`, press **Enter**.
2. Type `python --version` and press **Enter**.
   - **If it shows `Python 3.x.x`**, carry on.
   - **If it says "not found" or opens the Microsoft Store**, install Python from **https://www.python.org/downloads/**. On the first installer screen, **tick "Add python.exe to PATH"**, then click **Install Now**. Close and reopen Command Prompt.
3. Type:
   ```
   pip install mysql-connector-python
   ```
   If `pip` isn't recognised, use `python -m pip install mysql-connector-python`.

**✅ Check:** The last line says **"Successfully installed mysql-connector-python-…"**.

---

## Step 10: Set your login and run the script

1. Open the project folder in **File Explorer**, click the **address bar**, type `cmd` and press **Enter**. A Command Prompt opens inside the folder.
2. Create your config file:
   ```
   copy config.example.ini config.ini
   notepad config.ini
   ```
3. In Notepad, set:
   ```
   [mysql]
   host = localhost
   port = 3306
   user = root
   password = YOUR_ROOT_PASSWORD
   database = clearpoint
   ```
   Save with **Ctrl + S** and close Notepad.
4. Run:
   ```
   python run_queries.py
   ```

**✅ Check:** The last line reads **`10 of 10 queries ran successfully.`**

Other options:
```
python run_queries.py 7        (run only Q7)
python run_queries.py --list   (list all 10 queries)
```

> ⚠️ **Never upload `config.ini` to GitHub or share it.** It contains your password. Only `config.example.ini` belongs in the repository.

---

## Step 11: Run your constraint test for section 8

Each member runs **one** test from `constraint_tests.sql` and screenshots the error. The error **is** the correct result: it proves the database rejects bad data.

1. **File → Open SQL Script…** → `constraint_tests.sql`.
2. Find **your** test block (below).
3. Click inside **your INSERT/DELETE statement only** and press **Ctrl + Enter**. Do not click the lightning bolt, which runs every test.
4. Screenshot the **red ✗** row in the Output panel and send it to Nephtali.

| Test | Member | Expected error |
| --- | --- | --- |
| T1 | Amy | 1452, foreign key fails (claim for a policy that doesn't exist) |
| T2 | Rufaro | 3819, `ck_claim_closed` (closed before reported) |
| T3 | Harrison | 1062, duplicate entry for key PRIMARY (duplicate licence) |
| T4 | Ketsia | 1062, duplicate entry for `uq_client_id_number` |
| T5 | Thiana | 1451, cannot delete a parent row (client with policies) |
| T6 | Nephtali | 3819, `ck_claim_amount` (amount of 0) |

**✅ Check:** You got a red ✗ with the expected error code. Because the statement failed, your data is unchanged.

---

## Rules that keep all six databases identical

- **Never edit tables or rows by hand.** If something needs changing, tell Amy; she updates the files and everyone reruns Steps 7 and 8.
- **Always run `schema.sql` before `data.sql`.**
- **In any new query, use `DATE '2026-10-12'` instead of `CURDATE()` or `NOW()`**, so results don't change from day to day and the report screenshots stay correct.

---

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `Error Code: 1046. No database selected` | Run `USE clearpoint;` first, or add it as the first line of the script |
| `Duplicate entry …` while loading data | Run `schema.sql` again, then `data.sql` once |
| `verify.sql` numbers don't match | Re-download the files from GitHub and redo Step 7 |
| Script: `Access denied: check the user and password` | Fix the password in `config.ini` |
| Script: `Database 'clearpoint' does not exist` | Do Step 6, or fix the database name in `config.ini` |
| Script: `Cannot reach MySQL … is the server running?` | Open `services.msc`, right-click **MySQL84 → Start** |
| Script: `config.ini not found` | Do Step 10.2 in the project folder |
| `python` or `pip` not recognised | Reinstall Python with **"Add python.exe to PATH"** ticked, then reopen Command Prompt |
| Workbench "incompatible server version" warning | Click **Continue Anyway**; this is harmless |

**Stuck?** Post the exact error text in the group chat.
