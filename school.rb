class School < ActiveRecord::Base

  ActiveRecord::Base.establish_connection(
    adapter:  'sqlite3',
    database: 'development.sqlite3'
  )


validates :name, presence: true
  default_scope { order('name') }

end
