-- Great place for testing if SQL code is correct: http://sqlfiddle.com/#!17

CREATE TABLE Program(
  name TEXT PRIMARY KEY,
  abbreviation TEXT
);

CREATE TABLE Department(
  name TEXT PRIMARY KEY,
  abbreviation TEXT UNIQUE
);

CREATE TABLE Hosts(
  department TEXT,
  program TEXT,
  FOREIGN KEY (department) REFERENCES Department(name),
  FOREIGN KEY (program) REFERENCES Program(name),
  PRIMARY KEY (department, program)
);

CREATE TABLE Student(
  ssn TEXT PRIMARY KEY,
  name TEXT,
  login TEXT UNIQUE,
  program TEXT,
  FOREIGN KEY (program) REFERENCES Program(name),
  UNIQUE (ssn, program)
);

CREATE TABLE Branch(
  name TEXT,
  program TEXT,
  PRIMARY KEY (name, program),
  FOREIGN KEY (program) REFERENCES Program(name)
);

CREATE TABLE BelongsTo (
  student TEXT PRIMARY KEY,
  branch TEXT,
  program TEXT,
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (student, program) REFERENCES Student(ssn, program),
  FOREIGN KEY (branch, program) REFERENCES Branch(name, program)
);

CREATE TABLE Course (
  code TEXT PRIMARY KEY,
  name TEXT,
  credits INTEGER, -- Är det integer?
  department TEXT,
  FOREIGN KEY (department) REFERENCES Department(name)
);

CREATE TABLE Prerequisite (
  course TEXT,
  prerequisite TEXT,
  PRIMARY KEY (course, prerequisite),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (prerequisite) REFERENCES Course(code)
);

CREATE TABLE Classification (
  name TEXT PRIMARY KEY
);

CREATE TABLE Classified (
  course TEXT,
  classification TEXT,
  PRIMARY KEY (course, classification),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (classification) REFERENCES Classification(name)
);

CREATE TABLE MandatoryProgram (
  course TEXT,
  program TEXT,
  PRIMARY KEY (course, program),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (program) REFERENCES Program(name)
);

CREATE TABLE MandatoryBranch (
  course TEXT,
  branch TEXT,
  program TEXT,
  PRIMARY KEY (course, branch, program),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (branch, program) REFERENCES Branch(name, program)
);

CREATE TABLE RecommendedBranch (
  course TEXT,
  branch TEXT,
  program TEXT,
  PRIMARY KEY (course, branch, program),
  FOREIGN KEY (course) REFERENCES Course(code),
  FOREIGN KEY (branch, program) REFERENCES Branch(name, program)
);

CREATE TABLE Registered(
  student TEXT,
  course TEXT,
  PRIMARY KEY (student, course),
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (course) REFERENCES Course(code)
);

CREATE TYPE GRADE AS ENUM ('U', '3', '4', '5');

CREATE TABLE Taken(
  student TEXT,
  course TEXT,
  grade GRADE,
  PRIMARY KEY (student, course),
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (course) REFERENCES Course(code)
);

CREATE TABLE LimitedCourse(
  code TEXT PRIMARY KEY,
  seats INTEGER,
  FOREIGN KEY (code) REFERENCES Course(code)
);

CREATE TABLE WaitingList(
  student TEXT,
  course TEXT,
  PRIMARY KEY (student, course),
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (course) REFERENCES LimitedCourse(code),
  UNIQUE (student, course)
);
