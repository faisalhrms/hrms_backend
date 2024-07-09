class Task < ApplicationRecord
  ########## Validation ############
  # validates :goal, :uniqueness => true
  has_many :sub_tasks, :dependent => :destroy
end
