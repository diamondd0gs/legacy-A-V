require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

class School < ActiveRecord::Base

  default_scope { order('name') }

  validates :name, presence: true
end
