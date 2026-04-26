-- ============================================
-- TUITION CLASS MANAGEMENT SYSTEM
-- STEP 1: Create Tables
-- ============================================

-- Drop tables if they exist (for fresh start)
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS teachers;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS activity_log;

-- 1. Students Table
CREATE TABLE students (
    student_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(15),
    grade         VARCHAR(10),
    address       TEXT,
    joined_date   DATE DEFAULT (CURDATE()),
    status        ENUM('active','inactive') DEFAULT 'active'
);

-- 2. Teachers Table
CREATE TABLE teachers (
    teacher_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    phone         VARCHAR(15),
    subject       VARCHAR(50),
    salary        DECIMAL(10,2) DEFAULT 0.00,
    joined_date   DATE DEFAULT (CURDATE()),
    status        ENUM('active','inactive') DEFAULT 'active'
);

-- 3. Classes Table
CREATE TABLE classes (
    class_id      INT AUTO_INCREMENT PRIMARY KEY,
    class_name    VARCHAR(100) NOT NULL,
    subject       VARCHAR(50),
    teacher_id    INT,
    schedule      VARCHAR(100),
    max_students  INT DEFAULT 30,
    fee           DECIMAL(10,2) DEFAULT 0.00,
    status        ENUM('active','inactive') DEFAULT 'active',
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);

-- 4. Enrollments Table
CREATE TABLE enrollments (
    enroll_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_id    INT NOT NULL,
    class_id      INT NOT NULL,
    enroll_date   DATE DEFAULT (CURDATE()),
    payment_status ENUM('paid','pending','overdue') DEFAULT 'pending',
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id)   REFERENCES classes(class_id)   ON DELETE CASCADE,
    UNIQUE KEY unique_enroll (student_id, class_id)
);

-- 5. Payments Table
CREATE TABLE payments (
    payment_id    INT AUTO_INCREMENT PRIMARY KEY,
    enroll_id     INT NOT NULL,
    amount        DECIMAL(10,2),
    payment_date  DATE DEFAULT (CURDATE()),
    method        ENUM('cash','bank','online') DEFAULT 'cash',
    notes         TEXT,
    FOREIGN KEY (enroll_id) REFERENCES enrollments(enroll_id) ON DELETE CASCADE
);

-- 6. Activity Log Table (used by triggers)
CREATE TABLE activity_log (
    log_id        INT AUTO_INCREMENT PRIMARY KEY,
    action_type   VARCHAR(50),
    table_name    VARCHAR(50),
    description   TEXT,
    action_time   DATETIME DEFAULT NOW()
);

SELECT 'Tables created successfully!' AS status;
