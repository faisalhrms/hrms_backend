class ObjectiveComment < ApplicationRecord
  belongs_to 	:user
  belongs_to 	:objective_setting
end
