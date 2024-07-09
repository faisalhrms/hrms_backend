class ProvidentFund < ApplicationRecord

	####### Validations #########
  validates :name, :uniqueness => { scope: :company_id }

  ####### Relations #########
  belongs_to 	:company
  belongs_to  :employee_pay_item, 	foreign_key: :employee_pay_item_id, 	:class_name => "PayItem"
  belongs_to  :employer_pay_item, 	foreign_key: :employer_pay_item_id, 	:class_name => "PayItem"

  has_many 		:pay_executions,   	:dependent => :restrict_with_error

end
