"""
File:     run_queries.py
Project:  CSC312 Practical Assignment 2
          Clearpoint Financial Advisors: client, policy and claims database
Team:     Power Rangers
Members:  Rufaro Ruvarashe Chipoyera (4417552)
          Ketsia Elengemoke-Mbombo   (4397468)
          Amy Felix                  (4419804)
          Harrison Ibeh              (4276312)
          Thiana Moodley             (4323023)
          Nephtali Mwamba            (4492340)

Purpose:  Connects to the Clearpoint MySQL database and runs the 10 queries
          from queries.sql (report Section 6), printing each query's
          label, business question and results as a table.

Usage:    python run_queries.py            run all 10 queries
          python run_queries.py 7          run only query Q7
          python run_queries.py --list     list the queries without running them

Setup:    1. pip install mysql-connector-python
          2. load schema.sql and data.sql into your database first
          3. run the script; it will ask for your MySQL login
          (optional: a config.ini with a [mysql] section skips the prompts)

The script will ask for login details and we were not sure how the tutors can login and access our database but login details for anyone of us will work :) 
"""

import configparser
import getpass
import os
import re
import sys

try:
    import mysql.connector
    from mysql.connector import errorcode
except ImportError:
    print("The MySQL connector is not installed. Run:  pip install mysql-connector-python")
    sys.exit(1)

HERE = os.path.dirname(os.path.abspath(__file__))
CONFIG_FILE = os.path.join(HERE, "config.ini")


def find_queries_file():
    """Look for queries.sql next to the script, or in a sql/ subfolder."""
    for path in (os.path.join(HERE, "queries.sql"),
                 os.path.join(HERE, "sql", "queries.sql")):
        if os.path.exists(path):
            return path
    return os.path.join(HERE, "queries.sql")


QUERIES_FILE = find_queries_file()


def load_config(path=CONFIG_FILE):
    """Read the database login from config.ini (optional shortcut to skip the prompts)."""
    parser = configparser.ConfigParser()
    parser.read(path)
    if "mysql" not in parser:
        raise KeyError("config.ini must contain a [mysql] section.")
    db = parser["mysql"]
    return {
        "host": db.get("host", "localhost"),
        "port": db.getint("port", 3306),
        "user": db.get("user"),
        "password": db.get("password", ""),
        "database": db.get("database"),
    }


def ask(prompt, default=None, secret=False):
    """Prompt for a value; Enter accepts the default. Passwords are not echoed."""
    suffix = f" [{default}]" if default else ""
    text = f"{prompt}{suffix}: "
    value = getpass.getpass(text) if secret else input(text)
    return value.strip() or default or ""


def prompt_config():
    """Ask the person running the script for their MySQL login."""
    print("Enter your MySQL login (press Enter to accept the [default]).\n")
    return {
        "host": ask("Host", "localhost"),
        "port": int(ask("Port", "3306")),
        "user": ask("Username", "root"),
        "password": ask("Password", secret=True),
        "database": ask("Database", "CLEARPOINT"),
    }


def load_queries(path=QUERIES_FILE):
    """Split queries.sql into (label, question, sql) tuples.

    Each query in the file is preceded by comment lines; the first one is the
    label, e.g. "-- Q7 (Complex, Amy Felix): ...", and the rest describe the
    business question. A statement ends at a line ending with a semicolon.
    """
    with open(path, encoding="utf-8") as f:
        lines = f.read().splitlines()

    queries, comments, sql_lines = [], [], []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("--"):
            if not sql_lines:                      # comments that belong to the next query
                text = stripped.lstrip("-").strip()
                if text and not set(text) <= {"="}:
                    comments.append(text)
            continue
        if not stripped and not sql_lines:
            continue
        sql_lines.append(line)
        if stripped.endswith(";"):
            labels = [c for c in comments if re.match(r"Q\d+\b", c)]
            if labels:
                label = labels[-1]
                question = " ".join(comments[comments.index(label) + 1:])
                queries.append((label, question, "\n".join(sql_lines).strip()))
            comments, sql_lines = [], []
    return queries


def format_table(columns, rows):
    """Return rows as a plain-text table with column headings."""
    text_rows = [["NULL" if v is None else str(v) for v in row] for row in rows]
    widths = [len(c) for c in columns]
    for row in text_rows:
        widths = [max(w, len(v)) for w, v in zip(widths, row)]
    line = "+" + "+".join("-" * (w + 2) for w in widths) + "+"
    out = [line, "| " + " | ".join(c.ljust(w) for c, w in zip(columns, widths)) + " |", line]
    out += ["| " + " | ".join(v.ljust(w) for v, w in zip(row, widths)) + " |" for row in text_rows]
    out.append(line)
    return "\n".join(out)


def run_query(conn, label, question, sql):
    """Run one query and print its results. Returns True if it succeeded."""
    print("=" * 78)
    print(label)
    if question:
        print(question)
    print("-" * 78)
    cursor = conn.cursor()
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        columns = [d[0] for d in cursor.description]
        print(format_table(columns, rows))
        print(f"{len(rows)} row(s)\n")
        return True
    except mysql.connector.Error as err:
        print(f"ERROR running this query: {err}\n")
        return False
    finally:
        cursor.close()


def connect(cfg):
    """Open the connection, turning common failures into clear messages."""
    try:
        return mysql.connector.connect(**cfg)
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            msg = "Access denied: check the username and password."
        elif err.errno in (errorcode.ER_BAD_DB_ERROR, errorcode.ER_DBACCESS_DENIED_ERROR):
            msg = (f"Database '{cfg['database']}' does not exist: "
                   "check the database name, and that schema.sql and data.sql were loaded.")
        elif err.errno in (2003, 2005):
            msg = f"Cannot reach MySQL at {cfg['host']}:{cfg['port']}: is the server running?"
        else:
            msg = f"Could not connect to MySQL: {err}"
        raise ConnectionError(msg) from err


def main(argv):
    try:
        queries = load_queries()
    except FileNotFoundError:
        print(f"Cannot find queries.sql next to {os.path.basename(__file__)}. "
              "Run the script from the repository folder.")
        return 1

    if "--list" in argv:
        for label, _, _ in queries:
            print(label)
        return 0

    selected = queries
    numbers = [a for a in argv if a.isdigit()]
    if numbers:
        wanted = {f"Q{n}" for n in numbers}
        selected = [q for q in queries if q[0].split()[0] in wanted]
        if not selected:
            print(f"No query numbered {', '.join(numbers)}. Use --list to see the queries.")
            return 1

    try:
        cfg = load_config() if os.path.exists(CONFIG_FILE) else prompt_config()
        conn = connect(cfg)
    except (KeyError, ValueError, ConnectionError) as err:
        print(f"Setup problem: {err}")
        return 1
    except (KeyboardInterrupt, EOFError):
        print("\nCancelled.")
        return 1

    passed = 0
    try:
        print(f"\nConnected to '{cfg['database']}' on {cfg['host']}:{cfg['port']} "
              f"(MySQL {getattr(conn, 'server_info', None) or conn.get_server_info()})\n")
        for label, question, sql in selected:
            passed += run_query(conn, label, question, sql)
    finally:
        conn.close()

    print("=" * 78)
    print(f"{passed} of {len(selected)} queries ran successfully.")
    return 0 if passed == len(selected) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
