# Bash-DB

A lightweight Database Management System built entirely in Bash. It simulates core SQL operations using the filesystem — databases are directories, tables are files.

**ITI - Open Source Application Development (OSAD) - Intake 46**

## How It Works

```
.databases/
  └── mydb/                  # database = directory
        ├── students.meta    # table structure (columns, types, PK)
        └── students.data    # table data (pipe-separated rows)
```

- `.meta` files store column definitions: `col_name|col_type|PK`
- `.data` files store rows: `1|Alice|22`

## Features

**Database Operations:**
- Create, list, connect to, and drop databases

**Table Operations:**
- Create tables with typed columns (`int`, `string`, `float`) and primary keys
- List all tables with row counts
- Drop tables with confirmation
- Insert rows with type validation and PK uniqueness enforcement
- Select and display all rows in a formatted table
- Delete rows by primary key
- Update rows by primary key (keeps PK immutable)

## Usage

```bash
bash dbms.sh
```

Navigate through menus to manage databases and tables.

## Supported Data Types

| Type | Validation |
|------|-----------|
| `int` | Whole numbers only |
| `float` | Decimal numbers |
| `string` | Any text |

## Project Structure

| File | Purpose |
|------|---------|
| `dbms.sh` | Entry point, main menu, database operations |
| `table_ops.sh` | All table-level operations (CRUD) |

## Contributors

- **Karim** — [@Karim-308](https://github.com/Karim-308)
- **Mohamed** — [@muhammad-khaled-tech](https://github.com/muhammad-khaled-tech)
