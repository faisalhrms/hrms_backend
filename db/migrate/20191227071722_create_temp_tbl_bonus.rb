class CreateTempTblBonus < ActiveRecord::Migration[7.1]
  def change
    create_table :temp_tbl_bonus do |t|
    	t.string 	:emp_code
			t.float 	:jan, 	:default => 0.0
			t.float 	:feb, 	:default => 0.0
			t.float 	:mar, 	:default => 0.0
			t.float 	:apr, 	:default => 0.0
			t.float 	:may, 	:default => 0.0
			t.float 	:june, 	:default => 0.0
			t.float 	:july, 	:default => 0.0
			t.float 	:aug, 	:default => 0.0
			t.float 	:sep, 	:default => 0.0
			t.float 	:oct, 	:default => 0.0
			t.float 	:nov, 	:default => 0.0
			t.float 	:dec, 	:default => 0.0
			t.float 	:total, :default => 0.0
			t.float 	:bonus, :default => 0.0	
      t.timestamps
    end
  end
end
