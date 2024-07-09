class AddHiringShiftIdToEmployee < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :hiring_shift_id, :integer
    company = Company.find_by_is_active(true)
    Employee.pluck(:hiring_shift).uniq.each do |hiring_shift_name|
      if hiring_shift_name.present?
        puts hiring_shift_name
        shift = GeneralType.create(name: hiring_shift_name, company_id: company.id, type_name: 'hiring_shift')
        Employee.where(hiring_shift: hiring_shift_name).update_all(hiring_shift_id: shift.id)
      end
    end
  end
end
