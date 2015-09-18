class Reading < ActiveRecord::Base

  ActiveRecord::Base.establish_connection(
    adapter:  'sqlite3',
    database: 'development.sqlite3'
  )


validates :order_number, presence: true

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
