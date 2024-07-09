class CreateEmployeeDocument < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_documents do |t|
      t.integer  "employee_id"
      t.string   "document_name"
      t.string   "document_remarks"
      t.string   "avatar_file_name"
      t.string   "avatar_content_type"
      t.integer  "avatar_file_size"
      t.datetime "avatar_updated_at"
      t.datetime "created_at",                        null: false
      t.datetime "updated_at",                       null: false
    end
  end
end
