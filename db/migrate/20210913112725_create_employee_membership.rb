class CreateEmployeeMembership < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_memberships do |t|
      t.integer  "employee_id"
      t.string   "position_title"
      t.string   "institute_name"
      t.string   "remarks"
      t.datetime "start_date"
      t.datetime "end_date"
      t.string   "avatar_file_name"
      t.string   "avatar_content_type"
      t.integer  "avatar_file_size"
      t.datetime "avatar_updated_at"
      t.datetime "created_at",                        null: false
      t.datetime "updated_at",                        null: false
    end
  end
end
