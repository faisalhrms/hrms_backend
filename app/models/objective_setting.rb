class ObjectiveSetting < ApplicationRecord

  # ########## Validation ############
  # validates :name, :uniqueness => { scope: :company_id }
  # validates :code, :uniqueness => { scope: :company_id }

  ####### Relation Ship #########
  belongs_to 	:employee
  belongs_to 	:task
  belongs_to 	:sub_task
  has_many :objective_comments

  def task_goal
    if self.task.nil?
      return "-"
    else
      return self.task.goal
    end
  end

  def sub_task_kpi
    if self.sub_task.nil?
      return "-"
    else
      return self.sub_task.kpi
    end
  end

end
