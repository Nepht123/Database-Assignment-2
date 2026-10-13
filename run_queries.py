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
We were not sure how the tutors will access our database but any team member's login details can be used to access it
"""

import getpass
import os
import sys

try:
    import mysql.connector
except ImportError:
    sys.exit("Missing connector. Run:  pip install mysql-connector-python")

# queries.sql is in the same folder as this script
# Updated line: point to the sql subdirectory
QUERIES_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "queries.sql")


def read_queries():
    # Read queries.sql and return a list containing
    # the label, question, and SQL code for each query.

    queries = []

    label = ""
    question = ""
    sql = ""

    # Open the file and read it one line at a time.
    with open(QUERIES_FILE, encoding="utf-8") as file:

        for line in file:
            line = line.strip()

            # Check if this line is a comment.
            if line.startswith("--"):

                # Only read comments before the SQL starts.
                if sql == "":
                    text = line[2:].strip()

                    # Check if this comment starts a new question.
                    if text.startswith("Q") and len(text) > 1 and text[1].isdigit():
                        label = text
                        question = ""

                    # Add the question description to the question.
                    elif label != "" and text != "" and not text.startswith("="):
                        question = question + text + " "

            # Ignore empty lines.
            elif line != "":

                # Add this line to the SQL code.
                sql = sql + line + "\n"

                # A semicolon marks the end of a query.
                if line.endswith(";"):

                    # Save the query if it has a label.
                    if label != "":
                        queries.append((
                            label,
                            question.strip(),
                            sql.strip()
                        ))

                    # Reset the variables for the next query.
                    label = ""
                    question = ""
                    sql = ""

    # Return all the queries we collected.
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
    # Check if the queries.sql file exists.
    if not os.path.exists(QUERIES_FILE):
        sys.exit("Cannot find queries.sql. Run the script from the repository folder.")

    # Read all the queries from the file.
    queries = read_queries()

    # Get the query number entered when running the program.
    # For example: python run_queries.py 7
    wanted = sys.argv[1:]

    # Ask the user for their MySQL login details.
    print("Enter your MySQL login.\n")

    host = input("Host [localhost]: ").strip()

    # Use localhost if the user does not enter a host.
    if host == "":
        host = "localhost"

    port = input("Port: ").strip()

    # Check that the port contains only numbers.
    if not port.isdigit():
        sys.exit("Port must be a number.")

    user = input("Username: ").strip()
    password = getpass.getpass("Password: ")

    database = input("Database [CLEARPOINT]: ").strip()

    # Use CLEARPOINT if the user does not enter a database name.
    if database == "":
        database = "CLEARPOINT"

    # Try to connect to the MySQL database.
    try:
        conn = mysql.connector.connect(
            host=host,
            port=int(port),
            user=user,
            password=password,
            database=database
        )

    # Stop the program if the connection fails.
    except mysql.connector.Error as error:
        sys.exit("\nCould not connect: " + str(error))

    # Create a cursor to run SQL queries.
    cursor = conn.cursor()

    # Keep track of how many queries are run and succeed.
    total = 0
    passed = 0

    # Go through each query from queries.sql.
    for label, question, sql in queries:

        # If specific query numbers were entered, skip the others.
        if wanted != [] and query_number(label) not in wanted:
            continue

        # Count this query as one we are going to run.
        total = total + 1

        # Display the query heading and its description.
        print("\n" + "=" * 78)
        print(label)
        print(question)
        print("-" * 78)

        # Try to run the SQL query.
        try:
            cursor.execute(sql)

            # Get all the rows returned by the query.
            rows = cursor.fetchall()

            # Get the column names from the query result.
            columns = []
            for column in cursor.description:
                columns.append(column[0])

            # Display the results as a table.
            print_table(columns, rows)

            # Display the number of rows returned.
            print(len(rows), "row(s)")

            # Count this query as successful.
            passed = passed + 1

        # Display an error if the SQL query fails.
        except mysql.connector.Error as error:
            print("ERROR running this query:", error)

    # Close the cursor and database connection.
    cursor.close()
    conn.close()

    # Display the final results.
    print("\n" + "=" * 78)
    print(passed, "of", total, "queries ran successfully.")



main()
