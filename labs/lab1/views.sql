-- StudentsFollowing(student, program, branch)
CREATE VIEW StudentsFollowing AS
  SELECT Student.ssn AS student, Student.program, (SELECT branch FROM BelongsTo Where BelongsTo.student = Student.ssn)
  FROM Student;

-- FinishedCourses(student, course, grade, credits)
CREATE VIEW FinishedCourses AS
  SELECT Taken.student, Taken.course, Taken.grade, Course.credits
  FROM Taken, Course
  WHERE Course.code = Taken.course;

-- Registrations(student, course, status)
CREATE VIEW Registrations AS
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
CREATE VIEW PassedCourses AS
  SELECT Taken.student, Taken.course, Course.credits
  FROM Taken, Course
  WHERE (Taken.course = Course.code) AND (Taken.grade != 'U');

-- UnreadMandatory(student, course)
CREATE VIEW UnreadMandatory AS
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

-- PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, status)