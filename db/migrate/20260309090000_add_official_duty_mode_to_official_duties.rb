class AddOfficialDutyModeToOfficialDuties < ActiveRecord::Migration[7.1]
  def up
    add_column :official_duties, :official_duty_mode, :string, default: "Office Duty"

    execute <<~SQL.squish
      UPDATE official_duties
      SET official_duty_mode = 'Office Duty'
      WHERE official_duty_mode IS NULL OR official_duty_mode = ''
    SQL

    execute <<~SQL.squish
      UPDATE employee_attendances
      SET attendance_status = 'Office Duty'
      WHERE is_official_duty = TRUE AND attendance_status = 'On Official Duty'
    SQL
  end

  def down
    remove_column :official_duties, :official_duty_mode
  end
end
