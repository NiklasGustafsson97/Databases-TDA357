-- Great place for testing if SQL code is correct: http://sqlfiddle.com/#!17
-- Or even better https://www.db-fiddle.com

CREATE TABLE Program(
  name TEXT PRIMARY KEY,
  abbreviation TEXT NOT NULL
);

CREATE TABLE Department(
  name TEXT PRIMARY KEY,
  abbreviation TEXT NOT NULL UNIQUE
);

CREATE TABLE Hosts(
  department TEXT NOT NULL,
  program TEXT NOT NULL,
  FOREIGN KEY (department) REFERENCES Department(name),
  FOREIGN KEY (program) REFERENCES Program(name),
  PRIMARY KEY (department, program)
);

CREATE TABLE Student(
  ssn TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  login TEXT NOT NULL UNIQUE,
  program TEXT NOT NULL,
  FOREIGN KEY (program) REFERENCES Program(name),
  UNIQUE (ssn, program)
);

CREATE TABLE Branch(
  name TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY (name, program),
  FOREIGN KEY (program) REFERENCES Program(name)
);

CREATE TABLE BelongsTo (
  student TEXT PRIMARY KEY,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (student, program) REFERENCES Student(ssn, program),
  FOREIGN KEY (branch, program) REFERENCES Branch(name, program)
);

CREATE TABLE Course (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  credits NUMERIC NOT NULL CHECK (credits >= 0),
  department TEXT NOT NULL,
  FOREIGN KEY (department) REFERENCES Department(name)
);

CREATE TABLE Prerequisite (
  course TEXT NOT NULL,
  prerequisite TEXT NOT NULL,
  PRIMARY KEY (course, prerequisite),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (prerequisite) REFERENCES Course(code)
);

CREATE TABLE Classification (
  name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
  course TEXT NOT NULL,
  classification TEXT NOT NULL,
  PRIMARY KEY (course, classification),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (classification) REFERENCES Classification(name)
);

CREATE TABLE MandatoryProgram (
  course TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY (course, program),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (program) REFERENCES Program(name)
);

CREATE TABLE MandatoryBranch (
  course TEXT NOT NULL,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY (course, branch, program),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (branch, program) REFERENCES Branch(name, program)
);

CREATE TABLE RecommendedBranch (
  course TEXT NOT NULL,
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY (course, branch, program),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (branch, program) REFERENCES Branch(name, program)
);

CREATE TABLE Registered(
  student TEXT NOT NULL,
  course TEXT NOT NULL,
  PRIMARY KEY (student, course),
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (course) REFERENCES Course(code)
);

CREATE TYPE GRADE AS ENUM ('U', '3', '4', '5');

CREATE TABLE Taken(
  student TEXT NOT NULL,
  course TEXT NOT NULL,
  grade GRADE NOT NULL,
  PRIMARY KEY (student, course),
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (course) REFERENCES Course(code)
);

CREATE TABLE LimitedCourse(
  code TEXT PRIMARY KEY,
  seats INTEGER NOT NULL CHECK (seats >= 1),
  FOREIGN KEY (code) REFERENCES Course(code)
);

CREATE TABLE WaitingList(
  student TEXT NOT NULL,
  course TEXT NOT NULL,
  position INTEGER NOT NULL CHECK (position >= 1),
  PRIMARY KEY (student, course),
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (course) REFERENCES LimitedCourse(code),
  UNIQUE (position, course)
);


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
CREATE VIEW PathToGraduation AS
  SELECT Student.ssn AS student,
  COALESCE (totalCredits,0) AS totalCredits,
  COALESCE (mandatoryLeft,0) AS mandatoryLeft,
  COALESCE (mathCredits,0) AS mathCredits,
  COALESCE (researchCredits,0) AS researchCredits,
  COALESCE (seminarCourses,0) AS seminarCourses,
  COALESCE (mathCredits >= 20 AND researchCredits >= 10 AND seminarCourses >= 1 AND EXISTS(SELECT * FROM BelongsTo WHERE student = Student.ssn), FALSE) AS status
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

-- CourseQueuePositions(course, student, place)
CREATE VIEW CourseQueuePositions AS
  SELECT course, student, position AS place
  FROM WaitingList;


  -- Programs
INSERT INTO Program (name, abbreviation) VALUES ('Informationsteknik', 'IT');
INSERT INTO Program (name, abbreviation) VALUES ('Datateknik', 'D');
INSERT INTO Program (name, abbreviation) VALUES ('Arkitektur', 'A');

-- Departments
INSERT INTO Department (name, abbreviation) VALUES ('Data- och informationsteknik', 'DataIT');
INSERT INTO Department (name, abbreviation) VALUES ('Arkitektur och samhällsbyggnadsteknik', 'ArkSamhäll');

-- Hosts
INSERT INTO Hosts (department, program) VALUES ('Data- och informationsteknik', 'Informationsteknik');
INSERT INTO Hosts (department, program) VALUES ('Data- och informationsteknik', 'Datateknik');
INSERT INTO Hosts (department, program) VALUES ('Arkitektur och samhällsbyggnadsteknik', 'Arkitektur');

-- Student
INSERT INTO Student (ssn, name, login, program) VALUES ('8609232234', 'Marko Poker', 'pokerman', 'Informationsteknik');
INSERT INTO Student (ssn, name, login, program) VALUES ('8301128466', 'Sven Svensson', 'svenmos', 'Informationsteknik');
INSERT INTO Student (ssn, name, login, program) VALUES ('9006232476', 'Eva Johansson', 'evjas', 'Datateknik');
INSERT INTO Student (ssn, name, login, program) VALUES ('9606265689', 'Erik Karlsson', 'erikar', 'Arkitektur');
INSERT INTO Student (ssn, name, login, program) VALUES ('8209042134', 'Lina Persson', 'liaper', 'Informationsteknik');
INSERT INTO Student (ssn, name, login, program) VALUES ('8209232134', 'Karl Nope', 'kamnpe', 'Datateknik');
INSERT INTO Student (ssn, name, login, program) VALUES ('9503225546', 'Huggidugi Ekerstad', 'ehugo', 'Arkitektur');
INSERT INTO Student (ssn, name, login, program) VALUES ('4806035598', 'Edvino Majaer', 'skedie', 'Arkitektur');
INSERT INTO Student (ssn, name, login, program) VALUES ('9712127384', 'Zacko Macho', 'zackm', 'Informationsteknik');

-- Branch
INSERT INTO Branch (name, program) VALUES ('Computer Languages', 'Informationsteknik');
INSERT INTO Branch (name, program) VALUES ('Algorithms', 'Informationsteknik');
INSERT INTO Branch (name, program) VALUES ('Software Engineering', 'Informationsteknik');
INSERT INTO Branch (name, program) VALUES ('Computer Systems and Networks', 'Datateknik');
INSERT INTO Branch (name, program) VALUES ('Embedded Electronic System Design', 'Datateknik');
INSERT INTO Branch (name, program) VALUES ('Architecture and Urban Design', 'Arkitektur');
INSERT INTO Branch (name, program) VALUES ('Design and Construction Project Management', 'Arkitektur');

-- BelongsTo
INSERT INTO BelongsTo (student, branch, program) VALUES ('8301128466', 'Computer Languages', 'Informationsteknik');
INSERT INTO BelongsTo (student, branch, program) VALUES ('9606265689', 'Architecture and Urban Design', 'Arkitektur');
INSERT INTO BelongsTo (student, branch, program) VALUES ('9712127384', 'Algorithms', 'Informationsteknik');
INSERT INTO BelongsTo (student, branch, program) VALUES ('8609232234', 'Algorithms', 'Informationsteknik');

-- Course
INSERT INTO Course (code, name, credits, department) VALUES ('TDA357', 'Databases', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('DAT017', 'Maskinorienterad programmering', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('EDA433', 'Grundläggande datorteknik', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('MVE051', 'Matematisk statistik och diskret matematik', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('ARK505', 'Arbetets rum', 15, 'Arkitektur och samhällsbyggnadsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('MEM590', 'Grundläggande meme design', 15, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('MEM624', 'Memes och samhälle', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('MVE023', 'Addition i tiderna', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('MVE043', 'Division i tiderna', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('MVE046', 'Komplex addition', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('SEM245', 'Lego verkstad', 10, 'Data- och informationsteknik');

-- Prerequisite
INSERT INTO Prerequisite (course, prerequisite) VALUES ('DAT017', 'EDA433');
INSERT INTO Prerequisite (course, prerequisite) VALUES ('MVE043', 'MVE023');
INSERT INTO Prerequisite (course, prerequisite) VALUES ('MVE046', 'MVE043');
INSERT INTO Prerequisite (course, prerequisite) VALUES ('MEM624', 'MEM590');

-- Classification
INSERT INTO Classification (name) VALUES ('Mathematics');
INSERT INTO Classification (name) VALUES ('Research');
INSERT INTO Classification (name) VALUES ('Seminar');

-- Classified
INSERT INTO Classified (course, classification) VALUES ('MVE051', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MVE023', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MVE043', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MVE046', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MEM590', 'Research');
INSERT INTO Classified (course, classification) VALUES ('MEM624', 'Research');
INSERT INTO Classified (course, classification) VALUES ('SEM245', 'Seminar');

-- MandatoryProgram
INSERT INTO MandatoryProgram (course, program) VALUES ('DAT017', 'Informationsteknik');
INSERT INTO MandatoryProgram (course, program) VALUES ('EDA433', 'Informationsteknik');
INSERT INTO MandatoryProgram (course, program) VALUES ('MVE051', 'Informationsteknik');
INSERT INTO MandatoryProgram (course, program) VALUES ('MEM590', 'Datateknik');
INSERT INTO MandatoryProgram (course, program) VALUES ('MEM624', 'Datateknik');

-- MandatoryBranch
INSERT INTO MandatoryBranch (course, branch, program) VALUES ('MVE023', 'Algorithms', 'Informationsteknik');
INSERT INTO MandatoryBranch (course, branch, program) VALUES ('MVE043', 'Algorithms', 'Informationsteknik');
INSERT INTO MandatoryBranch (course, branch, program) VALUES ('MVE046', 'Algorithms', 'Informationsteknik');

-- RecommendedBranch
INSERT INTO RecommendedBranch (course, branch, program) VALUES ('MEM590', 'Algorithms', 'Informationsteknik');
INSERT INTO RecommendedBranch (course, branch, program) VALUES ('MEM624', 'Algorithms', 'Informationsteknik');

-- Registered
INSERT INTO Registered (student, course) VALUES ('8209042134', 'MEM590');
INSERT INTO Registered (student, course) VALUES ('8301128466', 'EDA433');
INSERT INTO Registered (student, course) VALUES ('8301128466', 'SEM245');
INSERT INTO Registered (student, course) VALUES ('9712127384', 'SEM245');

-- Taken
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'EDA433', '3');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'DAT017', '4');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'MVE051', '4');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'MEM590', '4');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'MEM624', '4');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'SEM245', '4');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'MVE023', '4');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'MVE043', '4');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'MVE046', '4');

-- LimitedCourse
INSERT INTO LimitedCourse (code, seats) VALUES ('EDA433', 1);
INSERT INTO LimitedCourse (code, seats) VALUES ('MEM590', 1);
INSERT INTO LimitedCourse (code, seats) VALUES ('SEM245', 1);

-- WaitingList
INSERT INTO WaitingList (student, course, position) VALUES ('8209232134', 'MEM590', 1);
INSERT INTO WaitingList (student, course, position) VALUES ('9712127384', 'MEM590', 2);
INSERT INTO WaitingList (student, course, position) VALUES ('8209232134', 'EDA433', 1);