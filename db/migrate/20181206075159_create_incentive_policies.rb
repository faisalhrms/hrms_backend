class CreateIncentivePolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :incentive_policies do |t|
    	t.integer 	:company_id
    	t.boolean 	:is_active, :default => false
    	t.string 		:name
    	t.text 			:description
      t.timestamps
    end
    add_index :incentive_policies, :company_id
  end
end
