/* This is the driving engine of the program. It parses the command-line
 * arguments and calls the appropriate methods in the other classes.
 *
 * You should edit this file in two ways:
 * 1) Insert your database username and password in the proper places.
 * 2) Implement the three functions getInformation, registerStudent
 *    and unregisterStudent.
 */
import java.sql.*; // JDBC stuff.
import java.util.Properties;
import java.util.Scanner;
import java.io.*;  // Reading user input.

public class StudentPortal
{
    /* TODO Here you should put your database name, username and password */
    static final String DATABASE = "jdbc:postgresql://localhost/lab4";
    static final String USERNAME = "postgres";
    static final String PASSWORD = "";

    /* Print command usage.
     * /!\ you don't need to change this function! */
    public static void usage () {
        System.out.println("Usage:");
        System.out.println("    i[nformation]");
        System.out.println("    r[egister] <course>");
        System.out.println("    u[nregister] <course>");
        System.out.println("    q[uit]");
    }

    /* main: parses the input commands.
     * /!\ You don't need to change this function! */
    public static void main(String[] args) throws Exception
    {
        try {
            Class.forName("org.postgresql.Driver");
            String url = DATABASE;
            Properties props = new Properties();
            props.setProperty("user",USERNAME);
            props.setProperty("password",PASSWORD);
            Connection conn = DriverManager.getConnection(url, props);


            String student = "4806035598"; // This is the identifier for the student.

            if(args.length != 0) {
                student = args[0];
            }

            //Console console = System.console();
            // In Eclipse. System.console() returns null due to a bug (https://bugs.eclipse.org/bugs/show_bug.cgi?id=122429)
            // In that case, use the following line instead:
            BufferedReader console = new BufferedReader(new InputStreamReader(System.in));
            usage();
            System.out.println("Welcome!");
            while(true) {
                System.out.print("? > ");
                String mode = console.readLine();
                String[] cmd = mode.split(" +");
                cmd[0] = cmd[0].toLowerCase();
                if ("information".startsWith(cmd[0]) && cmd.length == 1) {
                    /* Information mode */
                    getInformation(conn, student);
                } else if ("register".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Register student mode */
                    registerStudent(conn, student, cmd[1]);
                } else if ("unregister".startsWith(cmd[0]) && cmd.length == 2) {
                    /* Unregister student mode */
                    unregisterStudent(conn, student, cmd[1]);
                } else if ("quit".startsWith(cmd[0])) {
                    break;
                } else usage();
            }
            System.out.println("Goodbye!");
            conn.close();
        } catch (SQLException e) {
            System.err.println(e);
            System.exit(2);
        }
    }

    /* Given a student identification number, ths function should print
     * - the name of the student, the students national identification number
     *   and their issued login name (something similar to a CID)
     * - the programme and branch (if any) that the student is following.
     * - the courses that the student has read, along with the grade.
     * - the courses that the student is registered to. (queue position if the student is waiting for the course)
     * - the number of mandatory courses that the student has yet to read.
     * - whether or not the student fulfills the requirements for graduation
     */
    static void getInformation(Connection conn, String student) throws SQLException
    {
        // TODO: Your implementation here
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM Student WHERE Student.ssn=?");
        ps.setString(1, student);
        ResultSet studentRS = ps.executeQuery();
        if(!studentRS.next()) {
            throw new SQLException("No results found");
        }

        ps = conn.prepareStatement("SELECT * FROM StudentsFollowing WHERE StudentsFollowing.student=?");
        ps.setString(1, student);
        ResultSet studentsFollowingRS = ps.executeQuery();
        if(!studentsFollowingRS.next()) {
            throw new SQLException("No results found");
        }
        String branchName = studentsFollowingRS.getString("branch");
        String programName = studentRS.getString("program");

        ps = conn.prepareStatement("SELECT * FROM Program WHERE Program.name=?");
        ps.setString(1, programName);
        ResultSet programRS = ps.executeQuery();
        if(!programRS.next()) {
            throw new SQLException("No results found");
        }

        ps = conn.prepareStatement("SELECT * FROM FinishedCourses WHERE FinishedCourses.student=?");
        ps.setString(1, student);
        ResultSet finishedCoursesRS = ps.executeQuery();

        ps = conn.prepareStatement("SELECT * FROM Registrations WHERE Registrations.student=?");
        ps.setString(1, student);
        ResultSet registrationsRS = ps.executeQuery();

        ps = conn.prepareStatement("SELECT * FROM PathToGraduation WHERE student=?");
        ps.setString(1, student);
        ResultSet pathToGradRS = ps.executeQuery();
        if(!pathToGradRS.next()){
            throw new SQLException("No results found");
        }



        System.out.println("Information for student " + student);
        System.out.println("------------------------------------");

        System.out.println("Name: " + studentRS.getString("name"));
        System.out.println("Student ID: " + studentRS.getString("login"));
        System.out.println("Line: " + programName + " ("+ (programRS.getString("abbreviation")) + ")");
        System.out.println("Branch: " +  (branchName == null ? "" : branchName));
        System.out.println();

        System.out.println("Read courses (name (code), credits: grade):");
        while(finishedCoursesRS.next()) {
            String courseCode = finishedCoursesRS.getString("course");
            ps = conn.prepareStatement("SELECT * FROM Course WHERE Course.code=?");
            ps.setString(1, courseCode);
            ResultSet courseRS = ps.executeQuery();

            if(!courseRS.next())
                continue;

            System.out.println(" " + courseRS.getString("name") + " (" + courseCode + "), "
                    + finishedCoursesRS.getString("credits") + "p: " + finishedCoursesRS.getString("grade"));
        }
        System.out.println();

        System.out.println("Registered courses (name (code): status):");
        while(registrationsRS.next()) {
            String courseCode = registrationsRS.getString("course");
            ps = conn.prepareStatement("SELECT * FROM Course WHERE Course.code=?");
            ps.setString(1, courseCode);
            ResultSet courseRS = ps.executeQuery();

            if(!courseRS.next())
                continue;

            String status;
            if (registrationsRS.getString("status").equals("waiting")) {
                ps = conn.prepareStatement("SELECT place FROM CourseQueuePositions WHERE student=? AND course=?");
                ps.setString(1, student);
                ps.setString(2, courseCode);
                ResultSet courseQueuePositionsRS = ps.executeQuery();

                if(!courseQueuePositionsRS.next()) {
                    throw new SQLException("Expected student in coursequeuepositions, but found nothing");
                }
                status = "waiting as nr " + courseQueuePositionsRS.getString("place");
            } else {
                status = "registered";
            }

            System.out.println(" " + courseRS.getString("name") + " (" + courseCode + ") "
                    + status);
        }
        System.out.println();

        System.out.println("Seminar courses taken: " + pathToGradRS.getString("seminarCourses"));
        System.out.println("Math credit taken: " + pathToGradRS.getString("mathCredits"));
        System.out.println("Research credits taken: " + pathToGradRS.getString("researchCredits"));
        System.out.println("Total credits taken: " + pathToGradRS.getString("totalCredits"));
        System.out.println("Fulfills the requirements for graduation: " + pathToGradRS.getBoolean("status"));

        System.out.println();
    }

    /* Register: Given a student id number and a course code, this function
     * should try to register the student for that course.
     */
    static void registerStudent(Connection conn, String student, String course)
            throws SQLException
    {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO Registrations(student, course) VALUES (?,?)");
        ps.setString(1, student);
        ps.setString(2, course);
        ps.executeUpdate();

        ps = conn.prepareStatement("SELECT * FROM Registrations WHERE student=? AND course=?");
        ps.setString(1, student);
        ps.setString(2, course);
        ResultSet registrationsRS = ps.executeQuery();

        if(!registrationsRS.next()) {
            throw new SQLException("Student not found in WL or Reg");
        }

        ps = conn.prepareStatement("SELECT name FROM Course WHERE Course.code = ?");
        ps.setString(1, course);
        ResultSet courseRS = ps.executeQuery();

        if(!courseRS.next()) {
            throw new SQLException("Found no course with code " + course);
        }

        String status = registrationsRS.getString("status");
        if(status.equals("registered")) {
            System.out.println("You are now successfully registered to course " + course + " " + courseRS.getString("name"));
        } else {
            System.out.println("Course " + course + " " + courseRS.getString("name") + " is full, you are put in the waiting list.");
        }
    }

    /* Unregister: Given a student id number and a course code, this function
     * should unregister the student from that course.
     */
    static void unregisterStudent(Connection conn, String student, String course)
            throws SQLException
    {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM Registrations WHERE student=? AND course=?");
        ps.setString(1, student);
        ps.setString(2, course);
        ResultSet registrationsRS = ps.executeQuery();

        if(!registrationsRS.next()) {
            System.out.println("You are not registered for this course.");
            return;
        }

        ps = conn.prepareStatement("DELETE FROM Registrations WHERE student=? AND course=?");
        ps.setString(1, student);
        ps.setString(2, course);
        ps.executeUpdate();

        System.out.println("You were unregistered from the course " + course);
    }
}