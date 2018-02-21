CREATE FUNCTION register() RETURNS trigger AS $$
	BEGIN
		IF((SELECT Count(student) FROM Registered WHERE course = NEW.course) = SELECT seats FROM LimitedCourse WHERE code = NEW.course)
			INSERT INTO WaitingList(student, couse, position) VALUES (
				NEW.student,
				NEW.course,
				(SELECT Count(student) FROM WaitingList WHERE course = NEW.course)
			);

			RAISE EXCEPTION 'Cannot add student % to course % as it is full. Added to WaitingList', NEW.student, NEW.course;
		END IF;

		RETURN NEW;
	END
$$ LANGUAGE 'plpgsql';