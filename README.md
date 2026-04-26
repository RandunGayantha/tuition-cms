# 📚 Tuition Class Management System

A web-based Tuition Class Management System built with **PHP**, **MySQL**, and **PL/SQL** as part of the Advanced Database Management Systems (ADBMS) module assignment. The project focuses on demonstrating core SQL and PL/SQL concepts including stored procedures, functions, triggers, and cursors.

---

## ✨ Features

- 👨‍🎓 **Student Management** — Add, view, update, delete students
- 👨‍🏫 **Teacher Management** — Manage teachers with subject assignments
- 📖 **Class Management** — Create classes, assign teachers, set fees & capacity
- 📋 **Enrollment System** — Enroll students with automatic capacity validation
- 💰 **Payment Tracking** — Record payments and auto-update payment status
- 📊 **Reports** — Student reports, class enrollment stats, revenue by subject
- 📝 **Activity Log** — Trigger-generated audit trail of all key actions

---

## 🗄️ PL/SQL Objects

### Stored Procedures
| Procedure | Description |
|-----------|-------------|
| `EnrollStudent(student_id, class_id, OUT msg)` | Enrolls a student after checking capacity and duplicate enrollment |
| `RecordPayment(enroll_id, amount, method, OUT msg)` | Records payment and auto-updates payment status |
| `StudentReport(student_id)` | Uses a **CURSOR** to loop through and return all enrollments for a student |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `GetStudentTotalPaid(student_id)` | `DECIMAL` | Total amount paid by a student across all classes |
| `GetClassStudentCount(class_id)` | `INT` | Current number of students enrolled in a class |
| `IsClassFull(class_id)` | `VARCHAR` | Checks if a class has reached its maximum capacity |

### Triggers
| Trigger | Event | Description |
|---------|-------|-------------|
| `trg_after_student_insert` | AFTER INSERT on `students` | Logs new student registration to activity log |
| `trg_after_enrollment_insert` | AFTER INSERT on `enrollments` | Logs new enrollment to activity log |
| `trg_before_teacher_delete` | BEFORE DELETE on `teachers` | Prevents deleting a teacher who still has active classes |

---

## 🗃️ Database Schema

```
students        — student_id, full_name, email, phone, grade, address, status
teachers        — teacher_id, full_name, email, phone, subject, salary, status
classes         — class_id, class_name, subject, teacher_id, schedule, max_students, fee, status
enrollments     — enroll_id, student_id, class_id, enroll_date, payment_status
payments        — payment_id, enroll_id, amount, payment_date, method, notes
activity_log    — log_id, action_type, table_name, description, action_time
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML5, CSS3, JavaScript |
| Backend | PHP 8.x |
| Database | MySQL 8.x |
| Local Server | XAMPP |
| PL/SQL | MySQL Stored Procedures, Functions, Triggers, Cursors |

---

## ⚙️ Installation & Setup

### Prerequisites
- [XAMPP](https://www.apachefriends.org/download.html) (includes Apache + MySQL + PHP)
- A web browser
- Git (optional, for cloning)

---

### Step 1 — Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/tuition-cms.git
```

Or download the ZIP from GitHub and extract it.

---

### Step 2 — Copy to XAMPP

Copy the project folder into your XAMPP `htdocs` directory:

```
Windows:   C:\xampp\htdocs\tuition\
Mac/Linux: /opt/lampp/htdocs/tuition/
```

---

### Step 3 — Start XAMPP

Open XAMPP Control Panel and start:
- ✅ Apache
- ✅ MySQL

---

### Step 4 — Create the Database

1. Open browser → go to `http://localhost/phpmyadmin`
2. Click **New** on the left sidebar
3. Enter database name: `tuition_db`
4. Click **Create**

---

### Step 5 — Run SQL Files (in order)

In phpMyAdmin, select `tuition_db` → click the **SQL** tab → run each file:

| Order | File | What it does |
|-------|------|-------------|
| 1st | `sql/01_create_tables.sql` | Creates all 6 tables with constraints |
| 2nd | `sql/02_seed_data.sql` | Inserts sample students, teachers, classes, enrollments |
| 3rd | `sql/03_plsql.sql` | Creates all stored procedures, functions, and triggers |

---

### Step 6 — Configure Database Connection

Open `php/db.php` and update if needed:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');   // your MySQL username
define('DB_PASS', '');       // your MySQL password (blank by default in XAMPP)
define('DB_NAME', 'tuition_db');
```

---

### Step 7 — Open the App

Go to:

```
http://localhost/tuition/
```

---

## 📁 Project Structure

```
tuition/
├── sql/
│   ├── 01_create_tables.sql     # DDL — Table creation
│   ├── 02_seed_data.sql         # DML — Sample data
│   └── 03_plsql.sql             # Stored procedures, functions, triggers, cursors
│
├── php/
│   ├── db.php                   # Database connection
│   ├── header.php               # Sidebar navigation + global CSS
│   ├── index.php                # Dashboard
│   ├── students.php             # Student management
│   ├── teachers.php             # Teacher management
│   ├── classes.php              # Class management
│   ├── enrollments.php          # Enrollment (calls EnrollStudent procedure)
│   ├── payments.php             # Payments (calls RecordPayment procedure)
│   ├── reports.php              # Reports (calls StudentReport cursor procedure)
│   └── activity_log.php        # Trigger activity log viewer
│
└── README.md
```

---

## 🧪 SQL Concepts Demonstrated

- ✅ **DDL** — `CREATE TABLE` with primary keys, foreign keys, constraints
- ✅ **DML** — `INSERT`, `UPDATE`, `DELETE`, `SELECT` with `JOIN`, `GROUP BY`, `ORDER BY`
- ✅ **Stored Procedures** — with `IN`/`OUT` parameters and conditional logic
- ✅ **Functions** — `DETERMINISTIC` scalar functions
- ✅ **Triggers** — `AFTER INSERT`, `BEFORE DELETE`
- ✅ **Cursors** — declared and looped inside `StudentReport` procedure
- ✅ **Exception Handling** — `SIGNAL SQLSTATE` in trigger
- ✅ **Aggregate Functions** — `COUNT()`, `SUM()`, `COALESCE()`
- ✅ **Subqueries** — used in reporting queries

---

## 👥 Team Members

| Name | Index Number |
|------|-------------|
| Member 1 | XXXXXXXX |
| Member 2 | XXXXXXXX |
| Member 3 | XXXXXXXX |

---

## 📋 Module Details

- **Module:** Advanced Database Management Systems (ADBMS)
- **Assignment:** Web Application with SQL & PL/SQL Focus
- **System:** Tuition Class Management System

---

## 📄 License

This project is for academic purposes only.
