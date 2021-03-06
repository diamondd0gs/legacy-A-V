
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'development.sqlite3'
)

class Reading < ActiveRecord::Base


  validates :order_number, presence: true
  validates :lesson_id, presence: true
  validates :url, presence: true
  belongs_to :lessons

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
