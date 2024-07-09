class CreateCompositeLeaveTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :composite_leave_types do |t|
    	t.integer 	:leave_type_id
    	t.integer 	:merge_leave_type_id
    	t.string 		:status
      t.timestamps
    end
  end
end
