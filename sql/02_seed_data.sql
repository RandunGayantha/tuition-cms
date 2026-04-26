-- ============================================
-- STEP 2: Insert Sample Data
-- ============================================

-- Sample Teachers
INSERT INTO teachers (full_name, email, phone, subject, salary) VALUES
('Mr. Kamal Perera',   'kamal@tuition.lk',  '0771234567', 'Mathematics', 45000),
('Ms. Nimal Silva',    'nimal@tuition.lk',  '0772345678', 'Science',     42000),
('Mrs. Dilani Fernando','dilani@tuition.lk', '0773456789', 'English',     40000),
('Mr. Suresh Kumar',   'suresh@tuition.lk', '0774567890', 'ICT',         38000);

-- Sample Students
INSERT INTO students (full_name, email, phone, grade, address) VALUES
('Ashan Bandara',   'ashan@gmail.com',  '0751111111', 'Grade 10', 'Colombo'),
('Nadeesha Wijesiri','nadeesha@gmail.com','0752222222','Grade 11', 'Kandy'),
('Tharindu Jayawardena','tharindu@gmail.com','0753333333','Grade 10','Galle'),
('Chamari Dissanayake','chamari@gmail.com','0754444444','Grade 12','Matara'),
('Ruwan Pathirana',  'ruwan@gmail.com',  '0755555555', 'Grade 9',  'Negombo'),
('Ishara Gunasekara','ishara@gmail.com', '0756666666', 'Grade 11', 'Colombo'),
('Dilshan Rathnayake','dilshan@gmail.com','0757777777','Grade 10', 'Kurunegala'),
('Sachini Mendis',   'sachini@gmail.com','0758888888', 'Grade 12', 'Kandy');

-- Sample Classes
INSERT INTO classes (class_name, subject, teacher_id, schedule, max_students, fee) VALUES
('Maths Grade 10',    'Mathematics', 1, 'Mon/Wed 4pm-6pm', 25, 2500),
('Maths Grade 11',    'Mathematics', 1, 'Tue/Thu 4pm-6pm', 25, 2800),
('Science Grade 10',  'Science',     2, 'Mon/Wed 6pm-8pm', 20, 2200),
('English Spoken',    'English',     3, 'Sat 9am-12pm',    30, 1800),
('ICT Beginners',     'ICT',         4, 'Sun 9am-1pm',     20, 3000);

-- Sample Enrollments
INSERT INTO enrollments (student_id, class_id, payment_status) VALUES
(1, 1, 'paid'),
(2, 2, 'paid'),
(3, 1, 'pending'),
(4, 4, 'paid'),
(5, 3, 'pending'),
(6, 5, 'paid'),
(7, 1, 'overdue'),
(8, 2, 'paid'),
(1, 4, 'paid'),
(2, 5, 'pending');

-- Sample Payments
INSERT INTO payments (enroll_id, amount, method) VALUES
(1, 2500, 'cash'),
(2, 2800, 'bank'),
(4, 1800, 'cash'),
(6, 3000, 'online'),
(8, 2800, 'cash'),
(9, 1800, 'bank');

SELECT 'Sample data inserted!' AS status;
