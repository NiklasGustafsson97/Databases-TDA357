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
SELECT Student.ssn,
COALESCE (totalCredits,0) AS totalCredits,
COALESCE (mandatoryLeft,0) AS mandatoryLeft,
COALESCE (mathCredits,0) AS mathCredits,
COALESCE (researchCredits,0) AS researchCredits,
COALESCE (seminarCourses,0) AS seminarCourses,
COALESCE (mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses >= 1, FALSE) AS status
FROM
  Student
  FULL OUTER JOIN (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS totalCredits
    FROM PassedCourses
    GROUP BY PassedCourses.student
  ) TotalCredits
  ON Student.ssn = TotalCredits.student
  FULL OUTER JOIN (
    SELECT UnreadMandatory.student, COUNT(UnreadMandatory.course) AS mandatoryLeft
    FROM UnreadMandatory
    GROUP BY UnreadMandatory.student
  ) UnreadMandatory
  ON Student.ssn = UnreadMandatory.student
  FULL OUTER JOIN (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS mathCredits
    FROM PassedCourses
    WHERE PassedCourses.course IN (SELECT course FROM Classified WHERE classification = 'Mathematics')
    GROUP BY PassedCourses.student
  ) MathCredits
  ON Student.ssn = MathCredits.student
  FULL OUTER JOIN (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS researchCredits
    FROM PassedCourses
    WHERE PassedCourses.course IN (SELECT course FROM Classified WHERE classification = 'Research')
    GROUP BY PassedCourses.student
  ) ResearchCredits
  ON Student.ssn = ResearchCredits.student
  FULL OUTER JOIN (
    SELECT PassedCourses.student, COUNT(PassedCourses.course) AS seminarCourses
    FROM PassedCourses
    WHERE PassedCourses.course IN (SELECT course FROM Classified WHERE classification = 'Seminar')
    GROUP BY PassedCourses.student
  ) SeminarCourses
  ON Student.ssn = SeminarCourses.student;