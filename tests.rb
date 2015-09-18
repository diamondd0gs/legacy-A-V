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

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_lessons_have_names
    School.create(name: "Mathematics")
    s = School.new()
    refute s.save
  end

  def test_readings_have_number_order
    Reading.create(order_number: "45")
    r = Reading.new()
    refute r.save
  end
  # def test_create_new_school
  # assert School.create(name: "Anthony High School")
  # assert_raises(ArgumentError) do
  #   School.create(1, 2)
  #   end
  # end


  def test_truth
    assert true
  end

end
