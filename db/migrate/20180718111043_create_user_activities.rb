class CreateUserActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :user_activities do |t|
    	t.string :full_name, :default => ""
    	t.string :email, :default => ""
    	t.string :action_performed, :default => ""
      t.timestamps
    end
  end
end
