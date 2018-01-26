
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

-- Prerequisite
INSERT INTO Prerequisite (course, prerequisite) VALUES ('DAT017', 'EDA433');
INSERT INTO Prerequisite (course, prerequisite) VALUES ('MVE043', 'MVE023');
INSERT INTO Prerequisite (course, prerequisite) VALUES ('MVE046', 'MVE043');
INSERT INTO Prerequisite (course, prerequisite) VALUES ('MEM624', 'MEM590');

-- Classification
INSERT INTO Classification (name) VALUES ('Mathematics');
INSERT INTO Classification (name) VALUES ('Flum');

-- Classified
INSERT INTO Classified (course, classification) VALUES ('MVE051', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MVE023', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MVE043', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MVE046', 'Mathematics');
INSERT INTO Classified (course, classification) VALUES ('MEM590', 'Flum');
INSERT INTO Classified (course, classification) VALUES ('MEM624', 'Flum');

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
INSERT INTO Registered (student, course) VALUES ('8609232234', 'MEM590');
INSERT INTO Registered (student, course) VALUES ('8301128466', 'EDA433');

-- Taken
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'EDA433', '3');
INSERT INTO Taken (student, course, grade) VALUES ('8609232234', 'DAT017', '4');

-- LimitedCourse
INSERT INTO LimitedCourse (student, course) VALUES ('EDA433', 1);
INSERT INTO LimitedCourse (student, course) VALUES ('MEM590', 1);

-- WaitingList
INSERT INTO WaitingList (student, course) VALUES ('8209042134', 'MEM590');
INSERT INTO WaitingList (student, course) VALUES ('8209232134', 'EDA433');
INSERT INTO WaitingList (student, course) VALUES ('', '');		-- TODO

