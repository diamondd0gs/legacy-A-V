# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'


# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

    ActiveRecord::Migration.verbose = false

# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def setup
    # Gotta run migrations before we can run tests.  Down will fail the first time,
    # so we wrap it in a begin/rescue.
    begin ApplicationMigration.migrate(:down); rescue; end
    ApplicationMigration.migrate(:up)
  end

  def test_truth
    assert true
  end

  def test_lessons_must_have_names
    a = Lesson.create(name: "Mathematics")
    s = Lesson.create()
    assert a.save
    refute s.save
  end

  def test_readings_must_have_number_order
    a = Reading.create(order_number: 1, lesson_id: 45, url: "http://www.rubular.com")
    r = Reading.create(url: "cooladdress.com", lesson_id: 45)
    assert a.save
    refute r.save
  end

  def test_readings_must_have_lesson_id
    a = Reading.create(order_number: 1, lesson_id: 45, url: "http://www.rubular.com")
    r = Reading.create(order_number: 1, url: "cooladdress.com")
    assert a.save
    refute r.save
  end

  def test_readings_must_have_url
    a = Reading.create(order_number: 1, lesson_id: 45, url: "http://www.rubular.com")
    r = Reading.create(order_number: 1, lesson_id: 45)
    assert a.save
    refute r.save
  end

  def test_courses_must_have_course_code
    a = Course.create(name: "Mathematics", course_code: "mat101")
    c = Course.create(name: "Mathematics")
    assert a.save
    refute c.save
  end

  def test_courses_must_have_name
    a = Course.create(name: "Mathematics", course_code: "mat101")
    c = Course.create(course_code: "math")
    assert a.save
    refute c.save
  end

  def test_courses_must_have_unique_course_code_per_term
    a = Course.create(name: "Mathematics", course_code: "mat101")
    c = Term.create(name: "fall")
    a.term_id = c
    assert a.save

   b = Course.create(name: "Mathematics", course_code: "mat101")
   b.term_id = c
   refute b.save
  end

  def test_course_code_starts_3_letters_ends_3_numbers
    a = Course.create(name: "Intro to Mathematics", course_code: "MAT101")
    b = Course.create(name: "another course", course_code: "mat101")
    c = Course.create(name: "yet another course", course_code: "MATH101")

    assert a.save
    assert b.save
    refute c.save
  end

  def test_schools_and_terms_are_associated_correctly
    a = School.create(name: "Anthony High School")
    c = Term.create(name: "Fall 2015", starts_on: Date.today, ends_on: Date.today, school_id: 1)
    a.terms << c
    assert a.reload.terms.include?(c)
    assert_equal a, c.reload.school
  end

  def test_courses_and_terms_are_associated_correctly
    a = Term.create(name: "Fall 2015", starts_on: Date.today, ends_on: Date.today, school_id: 1)
    c = Course.create(name: "Intro to Mathematics", course_code: "MAT101")
    a.courses << c
    assert a.reload.courses.include?(c)
  end

  def test_courses_and_course_students_are_associated_correctly
    a = Course.create(name: "Intro to Mathematics", course_code: "MAT101")
    c = CourseStudent.create(student_id: "1")
    a.course_students << c
    assert a.reload.course_students.include?(c)
  end

def test_courses_and_assignments_are_associated_correctly
  a = Course.create(name: "Ruby", course_code: "RUB101")
  c = Assignment.create(name: "Battleship (MUAHAHAHAHA!)", percent_of_grade: 100)
  a.assignments << c
  assert a.reload.assignments.include?(c)
end

  #associations in lesson and reading
  def test_lessons_and_readings_dependent
    create_reading = Reading.create(order_number: "5", lesson_id: "1", url: "http://www.lesson.com")
    tuesday_lesson = Lesson.create(name: "Lesson")
    tuesday_lesson.readings << create_reading
    assert tuesday_lesson.reload.readings.include?(create_reading)
  end

  def test_lessons_destroyed_with_readings
    create_reading = Reading.create(order_number: "5", lesson_id: "1", url: "http://www.lesson.com")
    tuesday_lesson = Lesson.create(name: "Lesson")
    before = Lesson.count
    assert 1, Lesson.count
    tuesday_lesson.destroy
    assert_equal before -1, Lesson.count
  end

#associations in lesson and course
  def test_lessons_and_courses_dependent
    create_lesson = Lesson.create(name: "Regular Expressions")
    create_course = Course.create(name: "Ruby 101", course_code: "RUB101")
    create_course.lessons << create_lesson
    assert create_course.reload.lessons.include?(create_lesson)
  end

#associations in lesson and course
  def test_course_destroy_also_destroys_lessons
    create_lesson = Lesson.create(name: "Regular Expressions")
    create_course = Course.create(name: "Ruby 101", course_code: "RUB101")
    create_course.lessons << create_lesson
    before = Lesson.count
    assert 1, Lesson.count
    create_course.destroy
    assert_equal before - 1, Lesson.count
  end

  def test_cannot_destroy_courses_with_students
    create_course = Course.create(name: "Ruby 101", course_code: "RUB101")
    create_student = CourseStudent.create()
    create_course.course_students << create_student
    assert create_course.reload.course_students.include?(create_student)
    before = Course.count
    create_course.destroy
    refute_equal Course.count, before-1
  end

  def test_courses_have_readings_through_lessons
    create_course = Course.create(name: "Ruby 101", course_code: "RUB101")
    create_lesson = Lesson.create(name: "Regular Expressions")
    create_reading = Reading.create(order_number: "5", lesson_id: "1", url: "http://www.lesson.com")
    create_lesson.readings << create_reading
    create_course.lessons << create_lesson
    assert_equal [create_reading], create_course.readings
  end

#associations in course_instructor and course
def test_course_instructors_with_courses
  create_course = Course.create(name: "Ruby 101", course_code: "RUB101")
  instructor = CourseInstructor.create()
  # student = CourseStudent.create()
  create_course.course_instructors << instructor
  assert create_course.reload.course_instructors.include?(instructor)
end

def test_lessons_with_in_class_assignments
  create_lesson = Lesson.create(name: "create lesson")
  create_assignment = Assignment.create(name: "create assignment")
  create_assignment.lessons << create_lesson
  assert_equal [create_lesson], create_assignment.lessons
end

#validation in school
def test_schools_must_have_names
  a = School.create(name: "Grover C. Fields")
  s = School.create()
  assert a.save
  refute s.save
end

#validation in assignment
def test_assignments_have_a_course_id
  a = Assignment.create(name: "Friday Homework", course_id: 1, percent_of_grade: 100)
  b = Assignment.create(name: "Friday Homework", percent_of_grade: 100)
  assert a.save
  refute b.save
end

#validation in assignment
def test_assigments_have_names
  a = Assignment.create(name: "Friday Homework", course_id: 1, percent_of_grade: 100)
  b = Assignment.create(course_id: 1, percent_of_grade: 100)
  assert a.save
  refute b.save
end

#validation in assignment
def test_assignments_have_percent_of_grade
  a = Assignment.create(name: "Friday Homework", course_id: 1, percent_of_grade: 100)
  c = Assignment.create(name: "Friday Homework", course_id: 1)
  assert a.save
  refute c.save
end

#validation in assignment
def test_no_duplicate_assignments
  a = Assignment.create(name: "Friday Homework", course_id: 1, percent_of_grade: 100)
  e = Assignment.create(name: "Friday Homework", course_id: 1, percent_of_grade: 100)
  assert a.save
  refute e.save
end

#validation in user
def test_no_duplicate_emails
  a = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  f = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  assert a.save
  refute f.save
end

#validation in user
def test_user_has_first_name
  a = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  g = User.create(last_name: "Wayne", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  assert a.save
  refute g.save
end

#validation in user
def test_user_has_last_name
  a = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  h = User.create(first_name: "Bruce", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  assert a.save
  refute h.save
end

#validation in user
def test_user_has_email
  a = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  i = User.create(first_name: "Bruce", last_name: "Wayne", photo_url: "http://www.photobucket.com")
  refute i.save
end

#validation in user
def test_user_photo_uses_http
  a = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "http://www.photobucket.com")
  n = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "www.photobucket.com")
  o = User.create(first_name: "Bruce", last_name: "Wayne", email: "not.batman@batman.com", photo_url: "www.photobucket.com.http://")
  refute n.save
  refute o.save
  assert a.save
end

#validation in user
def test_user_email_is_appropriate
  assert User.create(first_name: "Bruce", last_name: "Wayne", photo_url: "http://www.photobucket.com", email: "fake_c@gmail.com")
  o = User.create(first_name: "Bruce", last_name: "Wayne", photo_url: "http://www.photobucket.com", email: "fakeagmail.com")
  q = User.create(first_name: "Bruce", last_name: "Wayne", photo_url: "http://www.photobucket.com", email: "fake@@gmail.com")
  r = User.create(first_name: "Bruce", last_name: "Wayne", photo_url: "http://www.photobucket.com", email: "fake@gmail")
  refute o.save
  refute q.save
  refute r.save
end

#validation in term
def test_term_has_name
  a = Term.create(name: "Fall 2015", starts_on: Date.today, ends_on: Date.today, school_id: 1)
  j = Term.create( starts_on: Date.today, ends_on: Date.today, school_id: 1)
  assert a.save
  refute j.save
end

#validation in term
def test_term_has_start_date
  a = Term.create(name: "Fall 2015", starts_on: Date.today, ends_on: Date.today, school_id: 1)
  j = Term.create(name: "Fall 2015", ends_on: Date.today, school_id: 1)
  assert a.save
  refute j.save
end

#validation in term
def test_term_has_end_date
  a = Term.create(name: "Fall 2015", starts_on: Date.today, ends_on: Date.today, school_id: 1)
  l = Term.create(name: "Fall 2015", starts_on: Date.today, school_id: 1)
  assert a.save
  refute l.save
end

#validation in term
def test_term_has_school_id
  a = Term.create(name: "Fall 2015", starts_on: Date.today, ends_on: Date.today, school_id: 1)
  m = Term.create(name: "Fall 2015", starts_on: Date.today, ends_on: Date.today)
  assert a.save
  refute m.save
end

end
