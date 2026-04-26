-- ============================================
-- STEP 3: PL/SQL - Stored Procedures, Functions, Triggers, Cursors
-- Run each block separately in phpMyAdmin
-- ============================================

-- Change delimiter for procedures
DELIMITER $$

-- ============================================
-- STORED PROCEDURE 1: Enroll a Student
-- Checks if class is full before enrolling
-- ============================================
CREATE PROCEDURE EnrollStudent(
    IN p_student_id INT,
    IN p_class_id   INT,
    OUT p_message   VARCHAR(200)
)
BEGIN
    DECLARE v_current_count INT;
    DECLARE v_max_students  INT;
    DECLARE v_class_name    VARCHAR(100);
    DECLARE v_student_name  VARCHAR(100);
    DECLARE already_enrolled INT DEFAULT 0;

    -- Get class info
    SELECT class_name, max_students INTO v_class_name, v_max_students
    FROM classes WHERE class_id = p_class_id;

    -- Get student name
    SELECT full_name INTO v_student_name
    FROM students WHERE student_id = p_student_id;

    -- Count current enrollments
    SELECT COUNT(*) INTO v_current_count
    FROM enrollments WHERE class_id = p_class_id;

    -- Check already enrolled
    SELECT COUNT(*) INTO already_enrolled
    FROM enrollments
    WHERE student_id = p_student_id AND class_id = p_class_id;

    IF already_enrolled > 0 THEN
        SET p_message = 'ERROR: Student is already enrolled in this class.';
    ELSEIF v_current_count >= v_max_students THEN
        SET p_message = CONCAT('ERROR: Class "', v_class_name, '" is full (', v_max_students, ' students max).');
    ELSE
        INSERT INTO enrollments (student_id, class_id, enroll_date, payment_status)
        VALUES (p_student_id, p_class_id, CURDATE(), 'pending');
        SET p_message = CONCAT('SUCCESS: ', v_student_name, ' enrolled in "', v_class_name, '" successfully!');
    END IF;
END$$


-- ============================================
-- STORED PROCEDURE 2: Record a Payment
-- Updates payment status after recording
-- ============================================
CREATE PROCEDURE RecordPayment(
    IN p_enroll_id  INT,
    IN p_amount     DECIMAL(10,2),
    IN p_method     VARCHAR(20),
    OUT p_message   VARCHAR(200)
)
BEGIN
    DECLARE v_fee DECIMAL(10,2);
    DECLARE v_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO v_exists FROM enrollments WHERE enroll_id = p_enroll_id;

    IF v_exists = 0 THEN
        SET p_message = 'ERROR: Enrollment not found.';
    ELSE
        -- Get class fee
        SELECT c.fee INTO v_fee
        FROM enrollments e
        JOIN classes c ON e.class_id = c.class_id
        WHERE e.enroll_id = p_enroll_id;

        -- Insert payment
        INSERT INTO payments (enroll_id, amount, payment_date, method)
        VALUES (p_enroll_id, p_amount, CURDATE(), p_method);

        -- Update enrollment payment status
        IF p_amount >= v_fee THEN
            UPDATE enrollments SET payment_status = 'paid' WHERE enroll_id = p_enroll_id;
            SET p_message = 'SUCCESS: Full payment recorded. Status updated to PAID.';
        ELSE
            UPDATE enrollments SET payment_status = 'pending' WHERE enroll_id = p_enroll_id;
            SET p_message = CONCAT('SUCCESS: Partial payment of Rs.', p_amount, ' recorded.');
        END IF;
    END IF;
END$$


-- ============================================
-- STORED PROCEDURE 3: Get Student Report (uses CURSOR)
-- Loops through all enrollments of a student
-- ============================================
CREATE PROCEDURE StudentReport(IN p_student_id INT)
BEGIN
    DECLARE v_done       INT DEFAULT FALSE;
    DECLARE v_class_name VARCHAR(100);
    DECLARE v_subject    VARCHAR(50);
    DECLARE v_schedule   VARCHAR(100);
    DECLARE v_fee        DECIMAL(10,2);
    DECLARE v_status     VARCHAR(20);
    DECLARE v_date       DATE;

    -- CURSOR: fetch all enrollments for the student
    DECLARE cur_enrollments CURSOR FOR
        SELECT c.class_name, c.subject, c.schedule, c.fee, e.payment_status, e.enroll_date
        FROM enrollments e
        JOIN classes c ON e.class_id = c.class_id
        WHERE e.student_id = p_student_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Temp table to hold results
    DROP TEMPORARY TABLE IF EXISTS student_report_result;
    CREATE TEMPORARY TABLE student_report_result (
        class_name    VARCHAR(100),
        subject       VARCHAR(50),
        schedule      VARCHAR(100),
        fee           DECIMAL(10,2),
        payment_status VARCHAR(20),
        enroll_date   DATE
    );

    OPEN cur_enrollments;
    read_loop: LOOP
        FETCH cur_enrollments INTO v_class_name, v_subject, v_schedule, v_fee, v_status, v_date;
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO student_report_result VALUES (v_class_name, v_subject, v_schedule, v_fee, v_status, v_date);
    END LOOP;
    CLOSE cur_enrollments;

    SELECT * FROM student_report_result;
    DROP TEMPORARY TABLE student_report_result;
END$$


-- ============================================
-- FUNCTION 1: Get Total Fees Paid by a Student
-- ============================================
CREATE FUNCTION GetStudentTotalPaid(p_student_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2) DEFAULT 0.00;

    SELECT COALESCE(SUM(p.amount), 0) INTO v_total
    FROM payments p
    JOIN enrollments e ON p.enroll_id = e.enroll_id
    WHERE e.student_id = p_student_id;

    RETURN v_total;
END$$


-- ============================================
-- FUNCTION 2: Count Students in a Class
-- ============================================
CREATE FUNCTION GetClassStudentCount(p_class_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_count INT DEFAULT 0;
    SELECT COUNT(*) INTO v_count FROM enrollments WHERE class_id = p_class_id;
    RETURN v_count;
END$$


-- ============================================
-- FUNCTION 3: Check if Class is Full
-- ============================================
CREATE FUNCTION IsClassFull(p_class_id INT)
RETURNS VARCHAR(5)
DETERMINISTIC
BEGIN
    DECLARE v_current INT;
    DECLARE v_max     INT;

    SELECT COUNT(*) INTO v_current FROM enrollments WHERE class_id = p_class_id;
    SELECT max_students INTO v_max FROM classes WHERE class_id = p_class_id;

    IF v_current >= v_max THEN
        RETURN 'YES';
    ELSE
        RETURN 'NO';
    END IF;
END$$


-- ============================================
-- TRIGGER 1: Log new student registration
-- ============================================
CREATE TRIGGER trg_after_student_insert
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, description, action_time)
    VALUES ('INSERT', 'students',
            CONCAT('New student registered: ', NEW.full_name, ' (ID:', NEW.student_id, ')'),
            NOW());
END$$


-- ============================================
-- TRIGGER 2: Log new enrollment
-- ============================================
CREATE TRIGGER trg_after_enrollment_insert
AFTER INSERT ON enrollments
FOR EACH ROW
BEGIN
    DECLARE v_student_name VARCHAR(100);
    DECLARE v_class_name   VARCHAR(100);

    SELECT full_name INTO v_student_name FROM students WHERE student_id = NEW.student_id;
    SELECT class_name INTO v_class_name  FROM classes  WHERE class_id   = NEW.class_id;

    INSERT INTO activity_log (action_type, table_name, description, action_time)
    VALUES ('INSERT', 'enrollments',
            CONCAT(v_student_name, ' enrolled in ', v_class_name),
            NOW());
END$$


-- ============================================
-- TRIGGER 3: Prevent deleting active teacher
-- who still has active classes
-- ============================================
CREATE TRIGGER trg_before_teacher_delete
BEFORE DELETE ON teachers
FOR EACH ROW
BEGIN
    DECLARE v_class_count INT;
    SELECT COUNT(*) INTO v_class_count
    FROM classes WHERE teacher_id = OLD.teacher_id AND status = 'active';

    IF v_class_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete teacher who still has active classes!';
    END IF;
END$$


DELIMITER ;

SELECT 'All PL/SQL objects created successfully!' AS status;
