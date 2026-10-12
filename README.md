# Database-Assignment-2


# Clearpoint Financial Advisors: Client, Policy and Claims Database

**CSC312 Practical 2: Database Design** | Team: **Power Rangers**

A relational database for Clearpoint Financial Advisors, an independent brokerage that sells insurance and investment products from multiple providers. It tracks clients, advisers, policies, claims, goals and compliance documents. A Python application script connects to the database and runs 10 SQL queries against it.

> Full design documentation (business rules, ERD, schema, normalisation) is in the project report and design document in this repository.

## Repository Structure

```
.
├── README.md
├── schema.sql              # CREATE TABLE statements and constraints
├── data.sql                # Sample INSERT data
├── queries.sql             # The 10 SQL queries
├── <script_file>           # Application script
├── <config_file>           # Database connection settings
└── docs/
    ├── <report_file>.docx
    └── Clearpoint_Database_Design.docx
```

## Prerequisites

- `<Python 3.x>`
- `<Database engine and version>`
- `<Required libraries, e.g. mysql-connector-python>`

Install dependencies:

```bash
<install command>
```

## Setup

1. **Clone the repository**

```bash
   git clone <repository-url>
   cd <repository-folder>
```

2. **Create the database**

```bash
   <command to create the database>
```

3. **Load the schema, then the data** (in this order)

```bash
   <command to run schema.sql>
   <command to run data.sql>
```

4. **Configure the connection**

   Open `<config_file>` and set your own database details:

```
   host=
   port=
   database=
   user=
   password=
```

## Running the Application

```bash
<run command>
```

The script connects to the database and executes all 10 queries from `queries.sql`, printing the results for each.

## Team

| Name | Student Number |

| Amy Felix (group leader) | 4419804 |

| Rufaro Ruvarashe Chipoyera | 4417552 |

| Harrison Ibeh | 4276312 |

| Ketsia Elengemoke-Mbombo | 4397468 |

| Thiana Moodley | 4323023 |

| Nephtali Mwamba | 4492340 |
