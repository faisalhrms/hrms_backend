if @employee_data.present?
  json.employee_data @employee_data.each do |employee_data|
    json.id 												employee_data.try(:id)
    json.employee_code 												employee_data.try(:employee_code)
    json.first_name      						employee_data.try(:first_name)
    json.last_name   							  employee_data.try(:last_name)
    json.date_of_joining   					ReportFormat.date_format(employee_data.try(:joining_date))
  end

  json.designation_data @designation_data.each do |designation_data|
    json.id 									designation_data.try(:id)
    json.name      						designation_data.try(:name)
  end

  json.grade_data @grade_data.each do |grade_data|
    json.id 									grade_data.try(:id)
    json.name      						grade_data.try(:name)
  end

  json.department_data @department_data.each do |department_data|
    json.id 									department_data.try(:id)
    json.name      						department_data.try(:name)
  end

  if @line_manager_data.present?
    json.line_manager_data @line_manager_data.each do |line_manager_data|
      json.id 												line_manager_data.try(:id)
      json.employee_code 												line_manager_data.try(:employee_code)
      json.first_name      						line_manager_data.try(:first_name)
      json.last_name   							  line_manager_data.try(:last_name)
    end
  end
end
json.line_manager_approval @objective_setting.try(:line_manager_approval)