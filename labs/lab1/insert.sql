
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
INSERT INTO Student (ssn, name, login, program) VALUES ('8301128466', 'Sven Svensson', 'svenmos', 'Informationsteknik');
INSERT INTO Student (ssn, name, login, program) VALUES ('9006232476', 'Eva Johansson', 'evjas', 'Datateknik');
INSERT INTO Student (ssn, name, login, program) VALUES ('9606265689', 'Erik Karlsson', 'erikar', 'Arkitektur');
INSERT INTO Student (ssn, name, login, program) VALUES ('8209042134', 'Lina Persson', 'liaper', 'Informationsteknik');

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

-- Course
INSERT INTO Course (code, name, credits, department) VALUES ('TDA357', 'Databases', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('DAT017', 'Maskinorienterad programmering', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('EDA433', 'Grundläggande datorteknik', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('MVE051', 'Matematisk statistik och diskret matematik', 7.5, 'Data- och informationsteknik');
INSERT INTO Course (code, name, credits, department) VALUES ('ARK505', 'Arbetets rum', 15, 'Arkitektur och samhällsbyggnadsteknik');

-- Prerequisite
INSERT INTO Prerequisite (course, prerequisite) VALUES ('DAT017', 'EDA433');

-- Classification
INSERT INTO Classification (name) VALUES ('Mathematics');

-- Classified
INSERT INTO Classified (course, classification) VALUES ('MVE051', 'Mathematics');

-- MandatoryProgram
INSERT INTO MandatoryProgram (course, program) VALUES ('DAT017', 'Informationsteknik');
INSERT INTO MandatoryProgram (course, program) VALUES ('EDA433', 'Informationsteknik');
INSERT INTO MandatoryProgram (course, program) VALUES ('MVE051', 'Informationsteknik');

-- RecommendedBranch
