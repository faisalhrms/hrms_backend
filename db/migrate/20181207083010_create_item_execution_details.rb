class CreateItemExecutionDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :item_execution_details do |t|
    	t.integer 		:pay_execution_id
    	t.integer 		:pay_item_id
    	t.string 			:status
      t.timestamps
    end
    add_index :item_execution_details, :pay_execution_id
    add_index :item_execution_details, :pay_item_id
  end
end
