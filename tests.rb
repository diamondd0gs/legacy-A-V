# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'
require './school.rb'
require './assignment.rb'

# Include both the migration and the app itself
require './migration'
require './application'

# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

ActiveRecord::Migration.verbose = false
# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

#validation in school
  def test_schools_must_have_names
    assert School.create(name: "Grover C. Fields")
    s = School.new()
    refute s.save
  end

#validation in assignment
  def test_assignments_have_a_course_id
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
    assert Assignment.create(name: "Friday Homework")
    e = Assignment.new(name: "Friday Homework")
    refute e.save
  end

#validation in user
  def test_no_duplicate_emails
    assert User.create(email: "fake@gmail.com")
    f = User.new(email: "fake@gmail.com")
    refute f.save
  end

  def test_user_has_first_name
    assert User.create(first_name: "Andy")
    g = User.new()
    refute g.save
  end

  def test_user_has_last_name
    assert User.create(last_name: "Warhol")
    h = User.new()
    refute h.save
  end

end
