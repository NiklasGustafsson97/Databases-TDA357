-- StudentsFollowing(student, program, branch)
SELECT Student.ssn AS student, Student.program, (SELECT branch FROM BelongsTo Where BelongsTo.student = Student.ssn)
FROM Student;

-- FinishedCourses(student, course, grade, credits)
SELECT Taken.student, Taken.course, Taken.grade, Course.credits
FROM Taken, Course
WHERE Course.code = Taken.course;

-- Registrations(student, course, status)
(
  SELECT Registered.student, Registered.course, 'registered' AS status
  FROM Registered
)
UNION
(
  SELECT WaitingList.student, WaitingList.course, 'waiting' AS status
  FROM WaitingList
);

-- PassedCourses(student, course, credits)
SELECT Taken.student, Taken.course, Course.credits
FROM Taken, Course
WHERE (Taken.course = Course.code) AND (Taken.grade != 'U');

-- UnreadMandatory(student, course)
(
  SELECT Student.ssn AS student, MandatoryProgram.course
  FROM Student, MandatoryProgram
  WHERE (Student.program = MandatoryProgram.program) AND (MandatoryProgram.course NOT IN (SELECT Taken.course FROM Taken WHERE Taken.student = Student.ssn))
)
UNION
(
  SELECT BelongsTo.student, MandatoryBranch.course
  FROM BelongsTo, MandatoryBranch
  WHERE (BelongsTo.branch = MandatoryBranch.branch) AND (MandatoryBranch.course NOT IN (SELECT Taken.course FROM Taken WHERE Taken.student = BelongsTo.student))
);

-- PathToGraduation