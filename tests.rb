# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require 'byebug'

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
    a = School.new(name: "Anthony High School")
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
    a.term = c
    assert a.save

    b = Course.new(name: "Mathematics", course_code: "mat101")
    b.term = c
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








end
