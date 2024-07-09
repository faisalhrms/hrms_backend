class AddQualficationTypeIdInQmployeeQualfications < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_qualifications, :qualfication_type_id, :integer
  end
end
