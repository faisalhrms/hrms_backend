class SubTask < ApplicationRecord
  ########## Validation ############
  # validates :kpi, :uniqueness => { scope: :task_id }
  belongs_to 	:task

  # before_destroy :check_sub_task_count

  # def check_sub_task_count
  #   if task.sub_tasks.count == 1
  #     errors.add(:base, 'Goal must have at-least one KPI')
  #     throw(:abort)
  #   end
  # end
end
