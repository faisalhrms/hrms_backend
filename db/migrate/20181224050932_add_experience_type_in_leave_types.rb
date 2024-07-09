class AddExperienceTypeInLeaveTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_types, :experience_type, :string, :default => "Day"
  end
end
