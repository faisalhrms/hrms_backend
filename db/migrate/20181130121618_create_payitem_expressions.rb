class CreatePayitemExpressions < ActiveRecord::Migration[7.1]
  def change
    create_table :payitem_expressions do |t|
			t.string 		:name
			t.float 		:expression_value, 	:default => 0.0
			t.boolean 	:is_active, 				:default => false
			t.text 			:description
      t.timestamps
    end
  end
end
