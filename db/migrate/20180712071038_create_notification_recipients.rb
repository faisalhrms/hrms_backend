class CreateNotificationRecipients < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_recipients do |t|
    	t.integer 		:recievable_id
    	t.string 			:recievable_type
			t.boolean 		:did_read, 		default: false
			t.boolean 		:archived, 		default: false
			t.string 			:content
			t.belongs_to 	:notification
      t.timestamps
    end
  end
end
