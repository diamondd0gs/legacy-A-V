
class School < ActiveRecord::Base

  ActiveRecord::Base.establish_connection(
    adapter:  'sqlite3',
    database: 'development.sqlite3'
  )

has_many :terms
validates :name, presence: true
  default_scope { order('name') }

require 'active_record'


  default_scope { order('name') }

  validates :name, presence: true

end
