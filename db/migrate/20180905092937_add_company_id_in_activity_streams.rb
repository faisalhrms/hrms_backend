class AddCompanyIdInActivityStreams < ActiveRecord::Migration[7.1]
  def change
  	add_column :user_activities, :company_id, :integer
  end
end
