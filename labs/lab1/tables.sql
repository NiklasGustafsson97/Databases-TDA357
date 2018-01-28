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
  credits INTEGER NOT NULL CHECK (credits >= 0),
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
  seats INTEGER NOT NULL CHECK (seats >= 0),
  FOREIGN KEY (code) REFERENCES Course(code)
);

CREATE TABLE WaitingList(
  student TEXT NOT NULL,
  course TEXT NOT NULL,
  PRIMARY KEY (student, course),
  FOREIGN KEY (student) REFERENCES Student(ssn),
  FOREIGN KEY (course) REFERENCES LimitedCourse(code),
  UNIQUE (student, course)
);
