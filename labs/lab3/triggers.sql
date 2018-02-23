--Trigger 1 (register)
CREATE OR REPLACE FUNCTION register() RETURNS trigger AS $$
	BEGIN
		--Check prereqs
		IF((SELECT Count(prerequisite) 
			FROM Prerequisite 
			WHERE (course = NEW.course) 
			AND (prerequisite NOT IN (SELECT course FROM Taken WHERE student = NEW.student))) > 0) -- Returns amount preqs that is NOT fulfilled

			THEN RAISE EXCEPTION '% has not fulfilled req for this course', NEW.student;
		END IF;

		--Check if student has completed course before
		IF(EXISTS(SELECT student FROM Taken WHERE student = NEW.student AND course = NEW.course AND grade != 'U'))
			THEN RAISE EXCEPTION '% has already completed course %', NEW.student, NEW.course;
		END IF;

		--Check if student already is in reg
		IF(EXISTS (SELECT student FROM Registered WHERE student = NEW.student AND course = NEW.course))
			THEN RAISE EXCEPTION '% is already registered on course %', NEW.student, NEW.course;
		END IF;

		--Check if course is limited. If not reg for course.
		IF(NOT EXISTS (SELECT code FROM LimitedCourse WHERE code = NEW.course))
			THEN 
			--Insert into register
			INSERT INTO Registered(student, course) VALUES (NEW.student, NEW.course);	
			RETURN NEW;
		END IF;

		--Check if student already in WL 
		IF(EXISTS (SELECT student FROM WaitingList WHERE student = NEW.student AND course = NEW.course))
			THEN RAISE EXCEPTION '% is already in waitinglist for course %', NEW.student, NEW.course;
		END IF;

		--Add to waitinglist if course is full
		IF((SELECT Count(student) FROM Registered WHERE course = NEW.course) >= (SELECT seats FROM LimitedCourse WHERE code = NEW.course))
			THEN INSERT INTO WaitingList(student, course, position) VALUES (
				NEW.student,
				NEW.course,
				((SELECT Count(student) FROM WaitingList WHERE course = NEW.course) + 1)
			);
			
			RETURN null;
		END IF;	

		--Insert into register - Limited course
		INSERT INTO Registered(student, course) VALUES (NEW.student, NEW.course);	

		RETURN NEW;
	END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER register
	INSTEAD OF INSERT ON Registrations
	FOR EACH ROW
	EXECUTE PROCEDURE register() ;


--Below is just test-stuffz
--INSERT INTO registered(student, course) VALUES ('9712127384', 'MVE023');
--SELECT * FROM registered;
--SELECT * FROM waitinglist;
--SELECT * FROM limitedcourse;


--Trigger 2(unregister)
CREATE OR REPLACE FUNCTION unregister() RETURNS trigger AS $$
	BEGIN

		--Check if not limitedcourse
		IF(NOT EXISTS (SELECT code FROM LimitedCourse WHERE code = OLD.course))
			THEN 
			DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
			RETURN NEW;
		END IF;

		--Check if student is in waiting list
		IF(EXISTS (SELECT student FROM WaitingList WHERE course = OLD.course AND student = OLD.student))
			THEN
			WITH student AS (DELETE FROM WaitingList WHERE course = OLD.course AND student = OLD.student RETURNING student, course, position)
				UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course AND position > position; 
			RETURN NEW;
		END IF;

		--Check if course is still full
		IF((SELECT Count(student) FROM Registered WHERE course = OLD.course) - 1 >= (SELECT seats FROM LimitedCourse WHERE code = OLD.course))
			THEN 
			DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
			RETURN NEW;
		END IF;

		--Check if there are no students in waitinglist
		IF(NOT EXISTS (SELECT student FROM WaitingList WHERE course = OLD.course))
			THEN
			DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
			RETURN NEW;
		END IF;
		
		--Remove student first student from waiting list and place in registered
		WITH student AS (DELETE FROM WaitingList WHERE course = OLD.course AND position = 1 RETURNING student, course)
			INSERT INTO Registered(student, course) SELECT student, course FROM student;
				
		UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course;

		DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
		RETURN NEW;
	END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER unregister
	INSTEAD OF DELETE ON Registrations
	FOR EACH ROW
	EXECUTE PROCEDURE unregister() ;

	--TESTING STUFF
--INSERT INTO registered(student, course) VALUES ('9712127384', 'MVE023');
--SELECT * FROM registered;
--SELECT * FROM waitinglist;
--SELECT * FROM limitedcourse;

--DELETE FROM Registered WHERE course = 'EDA433';