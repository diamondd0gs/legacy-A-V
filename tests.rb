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
    a = Lesson.new(name: "Mathematics")
    s = School.new()
    assert a.save
    refute s.save
  end

  def test_readings_must_have_number_order
    r = Reading.new(url: "cooladdress.com", lesson_id: 45)
    refute r.save
  end

  def test_readings_must_have_lesson_id
    r = Reading.new(order_number: 1, url: "cooladdress.com")
    refute r.save
  end

  def test_readings_must_have_url
    r = Reading.new(order_number: 1, lesson_id: 45)
    refute r.save
  end

  def test_courses_must_have_course_code
    a = Course.create(name: "Mathematics", course_code: "mat101")
    c = Course.new(name: "Mathematics")
    assert a.save
    refute c.save
  end

  def test_courses_must_have_name
    a = Course.create(name: "Mathematics", course_code: "mat101")
    c = Course.new(course_code: "math")
    assert a.save
    refute c.save
  end

  def test_courses_must_have_unique_course_code_per_term
    a = Course.create(name: "Mathematics", course_code: "mat101")
    c = Term.create(name: "fall")
    a.term_id = c
    assert a.save

   b = Course.new(name: "Mathematics", course_code: "mat101")
   b.term_id = c
   refute b.save
  end

  def test_course_code_starts_3_letters_ends_3_numbers
    a = Course.new(name: "Intro to Mathematics", course_code: "MAT101")
    b = Course.new(name: "another course", course_code: "mat101")
    c = Course.new(name: "yet another course", course_code: "MATH101")

    assert a.save
    assert b.save
    refute c.save
  end


  def test_schools_and_terms_are_associated_correctly
    a = School.create(name: "Anthony High School")
    c = Term.create(name: "fall")
    a.terms << c
    assert a.reload.terms.include?(c)
    assert_equal a, c.reload.school
  end

  def test_courses_and_terms_are_associated_correctly
    a = Term.create(name: "fall")
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
  c = Assignment.create(name: "Battleship (MUAHAHAHAHA!)")
  a.assignments << c
  assert a.reload.assignments.include?(c)
end

  #associations in lesson and reading
  def test_lessons_and_readings_dependent
    new_reading = Reading.create()
    tuesday_lesson = Lesson.create()
    tuesday_lesson.readings << new_reading
    assert tuesday_lesson.reload.readings.include?(new_reading)
  end

  def test_lessons_destroyed_with_readings
    new_reading = Reading.create()
    tuesday_lesson = Lesson.create()
    before = Lesson.count
    assert 1, Lesson.count
    tuesday_lesson.destroy
    assert_equal before - 1, Lesson.count
  end

#associations in lesson and course
  def test_lessons_and_courses_dependent
    new_lesson = Lesson.create()
    new_course = Course.create()
    new_course.lessons << new_lesson
    assert new_course.reload.lessons.include?(new_lesson)
  end

#associations in lesson and course
  def test_course_destroy_also_destroys_lessons
    new_lesson = Lesson.create()
    new_course = Course.create()
    new_course.lessons << new_lesson
    before = Lesson.count
    assert 1, Lesson.count
    new_course.destroy
    assert_equal before - 1, Lesson.count
  end

  def test_cannot_destroy_courses_with_students
    new_course = Course.create()
    new_student = CourseStudent.create()
    new_course.course_students << new_student
    assert new_course.reload.course_students.include?(new_student)
    before = Course.count
    new_course.destroy
    refute_equal Course.count, before-1
  end

  def test_courses_have_readings_through_lessons
    new_course = Course.create()
    new_lesson = Lesson.create()
    new_reading = Reading.create()
    new_lesson.readings << new_reading
    new_course.lessons << new_lesson
    assert_equal [new_reading], new_course.readings
  end

#associations in course_instructor and course
def test_course_instructors_with_courses
  new_course = Course.create()
  instructor = CourseInstructor.create()
  # student = CourseStudent.create()
  new_course.course_instructors << instructor
  assert new_course.reload.course_instructors.include?(instructor)
end

def test_lessons_with_in_class_assignments
  new_lesson = Lesson.create(name: "new lesson")
  new_assignment = Assignment.create(name: "new assignment")
  new_assignment.lessons << new_lesson
  assert_equal [new_lesson], new_assignment.lessons
end

#validation in school
def test_schools_must_have_names
  assert School.create(name: "Grover C. Fields")
  s = School.new()
  refute s.save
end

#validation in assignment
def test_assignments_have_a_course_id
  assert Assignment.create(course_id: 12)
  a = Assignment.new()
  refute a.save
end

#validation in assignment
def test_assigments_have_names
  assert Assignment.create(name: "Homework")
  b = Assignment.new()
  refute b.save
end

#validation in assignment
def test_assignments_have_percent_of_grade
  assert Assignment.create(percent_of_grade: 30)
  c = Assignment.new()
  refute c.save
end

#validation in assignment
def test_no_duplicate_assignments
  Assignment.create(name: "Friday Homework")
  e = Assignment.new(name: "Friday Homework")
  refute e.save
end

#validation in user
def test_no_duplicate_emails
  User.create(email: "fake@gmail.com")
  f = User.new(email: "fake@gmail.com")
  refute f.save
end

#validation in user
def test_user_has_first_name
  assert User.create(first_name: "Andy")
  g = User.new()
  refute g.save
end

#validation in user
def test_user_has_last_name
  assert User.create(last_name: "Warhol")
  h = User.new()
  refute h.save
end

#validation in user
def test_user_has_email
  assert User.create(email: "fake_a@gmail.com")
  i = User.new()
  refute i.save
end

#validation in user
def test_user_photo_uses_http
  assert User.create(photo_url: "http://www.photobucket.com")
  n = User.new(photo_url: "www.photobucket.com")
  o = User.new(photo_url: "www.photobucket.com.http://")
  refute n.save
  refute o.save
end

#validation in user
def test_user_email_is_appropriate
  assert User.create(email: "fake_c@gmail.com")
  o = User.new(email: "fakeagmail.com")
  q = User.new(email: "fake@@gmail.com")
  r = User.new(email: "fake@gmail")
  refute o.save
  refute q.save
  refute r.save
end

#validation in term
def test_term_has_name
  assert Term.create(name: "Fall 2015")
  j = Term.new()
  refute j.save
end

#validation in term
def test_term_has_start_date
  assert Term.create(starts_on: Date.today)
  k = Term.new()
  refute k.save
end

#validation in term
def test_term_has_end_date
  assert Term.create(ends_on: Date.today)
  l = Term.new()
  refute l.save
end

#validation in term
def test_term_has_school_id
  assert Term.create(school_id: 01)
  m = Term.new()
  refute m.save
end

end
