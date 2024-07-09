class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
    	t.references 	:notifiable, 	polymorphic: true
    	t.references 	:sendable, 		polymorphic: true
      t.timestamps
    end
  end
end
