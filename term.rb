ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'development.sqlite3'
)


class Term < ActiveRecord::Base
  belongs_to :school
  has_many :course

validates :id, uniqueness: true
validates :name, uniqueness: true

  default_scope { order('ends_on DESC') }

  scope :for_school_id, ->(school_id) { where("school_id = ?", school_id) }

  def school_name
    school ? school.name : "None"
  end

  def term()
  end
end
