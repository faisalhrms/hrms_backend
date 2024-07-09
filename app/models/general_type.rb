class GeneralType < ApplicationRecord
  belongs_to :company
  scope :hiring_shifts, -> {where(type_name: 'hiring_shift')}
  scope :get_by_company, -> (company_id){where(company_id: company_id)}
end
