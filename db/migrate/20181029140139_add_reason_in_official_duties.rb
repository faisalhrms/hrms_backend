class AddReasonInOfficialDuties < ActiveRecord::Migration[7.1]
  def change
  	add_column :official_duties, :reason, :text
  end
end
