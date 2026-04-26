<?php
require_once 'db.php';
$db = getDB();

$selected_student = isset($_GET['student_id']) ? (int)$_GET['student_id'] : 0;
$student_report   = [];
$student_info     = null;

// Call StudentReport stored procedure (uses CURSOR internally)
if($selected_student) {
    $student_info = $db->query("SELECT *, GetStudentTotalPaid($selected_student) AS total_paid
                                 FROM students WHERE student_id=$selected_student")->fetch_assoc();

    $db->multi_query("CALL StudentReport($selected_student)");
    if($result = $db->store_result()) {
        while($row = $result->fetch_assoc()) {
            $student_report[] = $row;
        }
        $result->free();
        // Clear remaining results
        while($db->more_results()) $db->next_result();
    }
}

$students = $db->query("SELECT * FROM students WHERE status='active' ORDER BY full_name");

// Overall stats
$stats = $db->query("
    SELECT
        (SELECT COUNT(*) FROM students WHERE status='active') AS total_students,
        (SELECT COUNT(*) FROM teachers WHERE status='active') AS total_teachers,
        (SELECT COUNT(*) FROM classes WHERE status='active')  AS total_classes,
        (SELECT COUNT(*) FROM enrollments)                    AS total_enrollments,
        (SELECT COALESCE(SUM(amount),0) FROM payments)        AS total_revenue,
        (SELECT COUNT(*) FROM enrollments WHERE payment_status='pending') AS pending_payments,
        (SELECT COUNT(*) FROM enrollments WHERE payment_status='overdue') AS overdue_payments
")->fetch_assoc();

// Top classes by enrollment
$top_classes = $db->query("
    SELECT c.class_name, c.subject, GetClassStudentCount(c.class_id) AS enrolled,
           c.max_students, c.fee,
           (GetClassStudentCount(c.class_id) * c.fee) AS potential_revenue
    FROM classes c WHERE c.status='active'
    ORDER BY enrolled DESC
");

include 'header.php';
?>

<div class="main">
    <div class="topbar"><h1>📊 Reports & Analytics</h1></div>

    <!-- Summary Stats -->
    <div class="stats-grid" style="grid-template-columns:repeat(4,1fr);">
        <div class="stat-card">
            <div class="stat-number"><?= $stats['total_students'] ?></div>
            <div class="stat-label">Active Students</div>
        </div>
        <div class="stat-card green">
            <div class="stat-number">Rs. <?= number_format($stats['total_revenue'],0) ?></div>
            <div class="stat-label">Total Revenue</div>
        </div>
        <div class="stat-card orange">
            <div class="stat-number"><?= $stats['pending_payments'] ?></div>
            <div class="stat-label">Pending Payments</div>
        </div>
        <div class="stat-card purple">
            <div class="stat-number"><?= $stats['overdue_payments'] ?></div>
            <div class="stat-label">Overdue Payments</div>
        </div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">

        <!-- Student Report using CURSOR Procedure -->
        <div class="card">
            <div class="card-header"><span class="card-title">🎓 Student Report (CURSOR)</span></div>

            <form method="GET" style="display:flex;gap:8px;margin-bottom:16px;">
                <select name="student_id" style="flex:1;padding:8px;border:1px solid #ddd;border-radius:6px;">
                    <option value="">-- Select Student --</option>
                    <?php while($s=$students->fetch_assoc()): ?>
                    <option value="<?= $s['student_id'] ?>" <?= $selected_student==$s['student_id']?'selected':'' ?>>
                        <?= htmlspecialchars($s['full_name']) ?>
                    </option>
                    <?php endwhile; ?>
                </select>
                <button type="submit" class="btn btn-primary">Generate</button>
            </form>

            <?php if($student_info): ?>
            <div style="background:#e8eaf6;padding:12px;border-radius:6px;margin-bottom:14px;">
                <strong><?= htmlspecialchars($student_info['full_name']) ?></strong> | <?= $student_info['grade'] ?><br>
                📞 <?= $student_info['phone'] ?> | 📧 <?= $student_info['email'] ?><br>
                <strong style="color:#2e7d32;">Total Paid: Rs. <?= number_format($student_info['total_paid'],2) ?></strong>
                <small>(using GetStudentTotalPaid() function)</small>
            </div>

            <?php if(count($student_report)): ?>
            <table>
                <thead><tr><th>Class</th><th>Subject</th><th>Fee</th><th>Status</th><th>Enrolled</th></tr></thead>
                <tbody>
                <?php foreach($student_report as $r): ?>
                <tr>
                    <td><strong><?= htmlspecialchars($r['class_name']) ?></strong></td>
                    <td><?= $r['subject'] ?></td>
                    <td>Rs. <?= number_format($r['fee'],2) ?></td>
                    <td><span class="badge badge-<?= $r['payment_status'] ?>"><?= strtoupper($r['payment_status']) ?></span></td>
                    <td><?= $r['enroll_date'] ?></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <?php else: ?>
            <p style="color:#888;">No enrollments found for this student.</p>
            <?php endif; ?>

            <small style="color:#888;margin-top:10px;display:block;">
                ⚡ <strong>CALL StudentReport(student_id)</strong> uses a CURSOR to loop through enrollments
            </small>

            <?php else: ?>
            <div style="text-align:center;padding:30px;color:#aaa;">
                Select a student to generate their report
            </div>
            <?php endif; ?>
        </div>

        <!-- Top Classes Report -->
        <div class="card">
            <div class="card-header"><span class="card-title">📈 Class Enrollment Report</span></div>
            <table>
                <thead><tr><th>Class</th><th>Enrolled</th><th>Max</th><th>Fee</th><th>Potential Revenue</th></tr></thead>
                <tbody>
                <?php while($c=$top_classes->fetch_assoc()): ?>
                <tr>
                    <td>
                        <strong><?= htmlspecialchars($c['class_name']) ?></strong><br>
                        <small style="color:#888;"><?= $c['subject'] ?></small>
                    </td>
                    <td>
                        <?= $c['enrolled'] ?> / <?= $c['max_students'] ?>
                        <div style="background:#eee;border-radius:3px;height:5px;margin-top:3px;">
                            <?php $pct = $c['max_students']>0 ? ($c['enrolled']/$c['max_students']*100) : 0; ?>
                            <div style="background:#1a237e;width:<?= min($pct,100) ?>%;height:5px;border-radius:3px;"></div>
                        </div>
                    </td>
                    <td><?= $c['max_students'] ?></td>
                    <td>Rs. <?= number_format($c['fee'],2) ?></td>
                    <td style="color:#2e7d32;font-weight:600;">Rs. <?= number_format($c['potential_revenue'],2) ?></td>
                </tr>
                <?php endwhile; ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Revenue by Subject Query -->
    <div class="card">
        <div class="card-header"><span class="card-title">💰 Revenue by Subject (GROUP BY Query)</span></div>
        <table>
            <thead><tr><th>Subject</th><th>Classes</th><th>Total Enrollments</th><th>Revenue Collected</th></tr></thead>
            <tbody>
            <?php
            $rev_by_subject = $db->query("
                SELECT c.subject,
                       COUNT(DISTINCT c.class_id) AS num_classes,
                       COUNT(e.enroll_id) AS total_enroll,
                       COALESCE(SUM(p.amount),0) AS revenue
                FROM classes c
                LEFT JOIN enrollments e ON c.class_id = e.class_id
                LEFT JOIN payments p ON e.enroll_id = p.enroll_id
                GROUP BY c.subject
                ORDER BY revenue DESC
            ");
            while($r=$rev_by_subject->fetch_assoc()): ?>
            <tr>
                <td><strong><?= $r['subject'] ?></strong></td>
                <td><?= $r['num_classes'] ?></td>
                <td><?= $r['total_enroll'] ?></td>
                <td style="color:#2e7d32;font-weight:700;">Rs. <?= number_format($r['revenue'],2) ?></td>
            </tr>
            <?php endwhile; ?>
            </tbody>
        </table>
    </div>
</div>
</body></html>
