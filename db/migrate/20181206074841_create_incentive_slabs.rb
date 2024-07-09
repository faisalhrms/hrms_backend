class CreateIncentiveSlabs < ActiveRecord::Migration[7.1]
  def change
    create_table :incentive_slabs do |t|
    	t.integer 	:incentive_policy_id
    	t.float 		:min_target_sale_percentage, 	:default => 0.0
    	t.float 		:max_target_sale_percentage, 	:default => 0.0
    	t.float 		:sale_incentive_percentage, 	:default => 0.0
      t.timestamps
    end
    add_index :incentive_slabs, :incentive_policy_id
  end
end
