"""
File:     run_queries.py
Project:  CSC312 Practical Assignment 2 - Clearpoint Financial Advisors
Team:     Power Rangers
Members:  Rufaro Ruvarashe Chipoyera (4417552)
          Ketsia Elengemoke-Mbombo   (4397468)
          Amy Felix                  (4419804)
          Harrison Ibeh              (4276312)
          Thiana Moodley             (4323023)
          Nephtali Mwamba            (4492340)

Runs the 10 queries in queries.sql against the CLEARPOINT MySQL database and prints each result as a table.
To run all queries python run_queries.py and to run a specific query python run_queries.py <query_number>
The script asks for your MySQL login details. The CLEARPOINT database must already be loaded (schema.sql, then data.sql).
We were not sure how the tutors will access our database but any team member's login details can be used to access the
"""

import getpass
import os
import sys

try:
    import mysql.connector
except ImportError:
    sys.exit("Missing connector. Run:  pip install mysql-connector-python")

# queries.sql is in the same folder as this script
QUERIES_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "queries.sql")


def read_queries():
    #Read queries.sql and return a list of (label, question, sql).
    
    queries = []
    label = ""
    question = ""
    sql = ""

    file = open(QUERIES_FILE, encoding="utf-8")
    for line in file:
        line = line.strip()

        if line.startswith("--"):
            # only read comments that come before the SQL of a query
            if sql == "":
                text = line[2:].strip()
                if text[:1] == "Q" and text[1:2].isdigit():
                    label = text                   # e.g. "Q7 (Complex, ...)"
                    question = ""
                elif label != "" and text != "" and not text.startswith("="):
                    question = question + text + " "

        elif line != "":
            sql = sql + line + "\n"
            if line.endswith(";"):                 # end of this query
                if label != "":
                    queries.append((label, question.strip(), sql.strip()))
                label = ""
                question = ""
                sql = ""

    file.close()
    return queries


def query_number(label):
    #Return the number in a label, e.g. 'Q7 (Complex...)' gives '7'.
    number = ""
    for character in label[1:]:
        if character.isdigit():
            number = number + character
        else:
            break
    return number


def print_row(values, widths):
    #Print one row of the table.
    cells = []
    for i in range(len(values)):
        cells.append(values[i].ljust(widths[i]))
    print("| " + " | ".join(cells) + " |")


def print_table(columns, rows):
    #Print the column names and rows as a text table.
    # turn every value into text (NULL for empty values)
    text_rows = []
    for row in rows:
        new_row = []
        for value in row:
            if value is None:
                new_row.append("NULL")
            else:
                new_row.append(str(value))
        text_rows.append(new_row)

    # each column is as wide as its longest value
    widths = []
    for i in range(len(columns)):
        width = len(columns[i])
        for row in text_rows:
            if len(row[i]) > width:
                width = len(row[i])
        widths.append(width)

    line = "+"
    for width in widths:
        line = line + "-" * (width + 2) + "+"

    print(line)
    print_row(columns, widths)
    print(line)
    for row in text_rows:
        print_row(row, widths)
    print(line)


def main():
    if not os.path.exists(QUERIES_FILE):
        sys.exit("Cannot find queries.sql. Run the script from the repository folder.")

    queries = read_queries()
    wanted = sys.argv[1:]          # e.g. ["7"] to run only Q7

    # ask for the login
    print("Enter your MySQL login.\n")
    host = input("Host [localhost]: ").strip()
    if host == "":
        host = "localhost"
    port = input("Port: ").strip()
    if not port.isdigit():
        sys.exit("Port must be a number.")
    user = input("Username: ").strip()
    password = getpass.getpass("Password: ")
    database = input("Database [CLEARPOINT]: ").strip()
    if database == "":
        database = "CLEARPOINT"

    # connect
    try:
        conn = mysql.connector.connect(host=host, port=int(port), user=user,
                                       password=password, database=database)
    except mysql.connector.Error as error:
        sys.exit("\nCould not connect: " + str(error))

    cursor = conn.cursor()
    total = 0
    passed = 0

    for label, question, sql in queries:
        if wanted != [] and query_number(label) not in wanted:
            continue

        total = total + 1
        print("\n" + "=" * 78)
        print(label)
        print(question)
        print("-" * 78)

        try:
            cursor.execute(sql)
            rows = cursor.fetchall()
            columns = []
            for column in cursor.description:
                columns.append(column[0])
            print_table(columns, rows)
            print(len(rows), "row(s)")
            passed = passed + 1
        except mysql.connector.Error as error:
            print("ERROR running this query:", error)

    cursor.close()
    conn.close()

    print("\n" + "=" * 78)
    print(passed, "of", total, "queries ran successfully.")


main()
