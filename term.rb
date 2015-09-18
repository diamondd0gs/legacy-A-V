class Term < ActiveRecord::Base
  belongs_to :schools

  default_scope { order('ends_on DESC') }

  scope :for_school_id, ->(school_id) { where("school_id = ?", school_id) }

  def school_name
    school ? school.name : "None"
  end

  def term()
  end
end
