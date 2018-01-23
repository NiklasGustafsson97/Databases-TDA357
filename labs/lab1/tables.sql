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