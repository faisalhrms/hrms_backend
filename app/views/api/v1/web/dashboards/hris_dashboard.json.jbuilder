json.hris_dashboard do
  json.on_roll_strength			@on_roll_strength.count
  json.retirement_count 		@employee_list.where('date_of_birth >= ? AND date_of_birth <= ?',(Date.today - 720.to_i.months),(Date.today - 714.to_i.months)).count
  json.contract_end_count 	@employee_list.where(:is_contractual => true).where('contract_end_date >= ? AND contract_end_date <= ?',(Date.today.beginning_of_month - 1.to_i.months),(Date.today.end_of_month - 0.to_i.months)).count
end

location_list = []
management_male = []
non_management_male = []
management_female = []
non_management_female = []

department_list = []
dept_wise_strength = []

cities_list = []
cities_wise_strength = []

employee_type_list = []
employee_type_wise_strength = []

employee_religion = []

grade_level_list = ["Senior-Management", "Middle-Management", "Junior-Management", "Non-Management"]
grade_level_wise_strength = []
grade_list = []
grade_wise_strength = []

grade_level_wise_strength << @employee_list.where(:grade_id => @senior_management_tier).count
grade_level_wise_strength << @employee_list.where(:grade_id => @middle_management_tier).count
grade_level_wise_strength << @employee_list.where(:grade_id => @junior_management_tier).count
grade_level_wise_strength << @employee_list.where(:grade_id => @non_management_tier).count

@branches.each do |branch|
  location_list 					<< branch.name
  management_male 				<< @employee_list.where(:branch_id => branch.id, :grade_id => @management_grade_ids, :gender => "Male").count
  non_management_male 		<< @employee_list.where(:branch_id => branch.id, :grade_id => @non_management_grade_ids, :gender => "Male").count
  management_female 			<< @employee_list.where(:branch_id => branch.id, :grade_id => @management_grade_ids, :gender => "Female").count
  non_management_female 	<< @employee_list.where(:branch_id => branch.id, :grade_id => @non_management_grade_ids, :gender => "Female").count
end

male_data = []
female_data = []
management_data = []
non_management_data = []

@branches.each do |branch|
  male_data 			<< @employee_list.where(:branch_id => branch.id, :gender => "Male").count
  female_data			<< @employee_list.where(:branch_id => branch.id, :gender => "Female").count
end

@branches.each do |branch|
  management_data 				<< @employee_list.where(:branch_id => branch.id, :grade_id => @management_grade_ids).count
  non_management_data 		<< @employee_list.where(:branch_id => branch.id, :grade_id => @non_management_grade_ids).count
end


json.male_data 							male_data
json.female_data 						female_data

json.management_data 				management_data
json.non_management_data 		non_management_data

json.location_list 					location_list
json.management_male 				management_male
json.non_management_male 		non_management_male
json.management_female 			management_female
json.non_management_female 	non_management_female


management_type_list = ["Management", "Non-Management"]
management_type_data = []
non_management_type_data = []

management_type_data 				<< @employee_list.where(:grade_id => @management_grade_ids).count
non_management_type_data 		<< @employee_list.where(:grade_id => @non_management_grade_ids).count

json.employees_by_gender Array.new(2).each_index do |index|
  if index == 0
    color	= "#73C6B6"
    json.y 				@employee_list.where(:gender => "Male").count
    json.name			"Male"
    json.selected true
    json.color		color
  elsif index == 1
    color	= '#EC7063'
    json.y 				 @employee_list.where(:gender => "Female").count
    json.name			"Female"
    json.selected false
    json.color		color
  end
end

json.employees_by_bloodgroup Array.new(6).each_index do |index|
  if index == 0
    json.y 				@employee_list.where(:blood_group => "A+").count
    json.name			"A+"
  elsif index == 1
    json.y 				 @employee_list.where(:blood_group => "A-").count
    json.name			"A-"
  elsif index == 2
    json.y 				 @employee_list.where(:blood_group => "O+").count
    json.name			"O+"
  elsif index == 3
  json.y 				 @employee_list.where(:blood_group => "O-").count
  json.name			"O-"
  elsif index == 2
    json.y 				 @employee_list.where(:blood_group => "B+").count
    json.name			"B+"
  elsif index == 3
    json.y 				 @employee_list.where(:blood_group => "B-").count
    json.name			"B-"
    json.selected false
  elsif index == 4
    json.y 				 @employee_list.where(:blood_group => "AB+").count
    json.name			"AB+"
  elsif index == 5
    json.y 				 @employee_list.where(:blood_group => "AB-").count
    json.name			"AB-"
  end
end

json.employees_martial_status Array.new(4).each_index do |index|
  if index == 0
    json.y 				@employee_list.where(:martial_status => "Single").count
    json.name			"Single"
  elsif index == 1
    json.y 				 @employee_list.where(:martial_status => "Married").count
    json.name			"Married"
    elsif index == 2
      json.y 				@employee_list.where(:martial_status => "Divorced").count
      json.name			"Divorced"
    elsif index == 3
      json.y 				 @employee_list.where(:martial_status => "Widowed").count
      json.name			"Widowed"
  end
end


json.employee_religion @employee_religions.each do |religion|
  color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
  json.label 	religion.name
  json.value 	@employee_list.where(:religion_id => religion.id).count
  json.color	color
  employee_religion << color
end


json.management_type_list 			management_type_list
json.management_type_data 			management_type_data
json.non_management_type_data 	non_management_type_data

@departments.each do |department|
  department_list 		<< department.name
  dept_wise_strength 	<< @employee_list.where(:department_id => department.id).count
end

json.department_list 					department_list
json.dept_wise_strength 			dept_wise_strength

@cities.each do |city|
  cities_list 					<< city.name
  cities_wise_strength 	<< @employee_list.where(:current_city_id => city.id).count
end

json.cities_list 							cities_list
json.cities_wise_strength 		cities_wise_strength

@employee_types.each do |employee_type|
  employee_type_list 						<< employee_type.name
  employee_type_wise_strength 	<< @employee_list.where(:employee_type_id => employee_type.id).count
end


json.employee_type_list 					employee_type_list
json.employee_type_wise_strength 	employee_type_wise_strength

json.employee_qualifications_strength Array.new(7).each_index do |index|
  if index == 0
    json.y 				EmployeeQualification.where(:employee_id => @employee_list.pluck(:id),:qualification_level => "Under Matric").count
    json.name			"Under Matric"
  elsif index == 1
    json.y 				 EmployeeQualification.where(:employee_id => @employee_list.pluck(:id),:qualification_level => "Matric").count
    json.name			"Matric"
  elsif index == 2
    json.y 				EmployeeQualification.where(:employee_id => @employee_list.pluck(:id),:qualification_level => "Intermediate").count
    json.name			"Intermediate"
  elsif index == 3
    json.y 				 EmployeeQualification.where(:employee_id => @employee_list.pluck(:id),:qualification_level => "Graduation").count
    json.name			"Graduation"
  elsif index == 4
    json.y 				 EmployeeQualification.where(:employee_id => @employee_list.pluck(:id),:qualification_level => "Post Graduation").count
    json.name			"Post Graduation"
  elsif index == 5
    json.y 				 EmployeeQualification.where(:employee_id => @employee_list.pluck(:id),:qualification_level => "M-Phil").count
    json.name			"M-Phil"
  elsif index == 6
    json.y 				 EmployeeQualification.where(:employee_id => @employee_list.pluck(:id),:qualification_level => "PHD").count
    json.name			"PHD"
  end
end


@employee_grades.each do |employee_grade|
  grade_list 						<< employee_grade.name
  grade_wise_strength 	<< @employee_list.where(:grade_id => employee_grade.id).count
end

json.grade_list 					grade_list
json.grade_wise_strength 	grade_wise_strength

json.grade_level_list 					grade_level_list
json.grade_level_wise_strength 	grade_level_wise_strength

location_ids = [1]
if not params[:location_ids].blank?
  location_ids = params[:location_ids].map(&:to_i)
end
if location_ids.include?(1) == true
  json.comparsion_list 							["2020", "2019", "2018", "2017", "2016"]
  json.comparsion_strength 					[@on_roll_strength.count, 289, 214, 202, 212]
else
  json.comparsion_list 							["2020", "2019", "2018", "2017", "2016"]
  json.comparsion_strength 					[@on_roll_strength.count, 0.0, 0.0, 0.0, 0.0]
end

json.strenght_tier_wise Array.new(4).each_index do |index|
  if index == 0
    color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.y 				((@employee_list.where(:grade_id => @senior_management_tier).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"Senior-Management"
    json.selected true
    json.color		color
  elsif index == 1
    color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.y 				((@employee_list.where(:grade_id => @middle_management_tier).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"Middle-Management"
    json.selected false
    json.color		color
  elsif index == 2
    color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.y 				((@employee_list.where(:grade_id => @junior_management_tier).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"Junior-Management"
    json.selected false
    json.color		color
  elsif index == 3
    color	= "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.y 				((@employee_list.where(:grade_id => @non_management_tier).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"Non-Management"
    json.selected false
    json.color		color
  end
end



json.employees_by_ages Array.new(7).each_index do |index|
  if index == 0
    color	= "#D98880"
    json.y 				((@employee_list.where('date_of_birth >= ? AND date_of_birth <= ?',(Date.today - 18.to_i.years),(Date.today - 0.to_i.years)).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"0-18 Age"
    json.selected true
    json.color		color
  elsif index == 1
    color	= "#C39BD3"
    json.y 				((@employee_list.where('date_of_birth > ? AND date_of_birth <= ?',(Date.today - 30.to_i.years),(Date.today - 18.to_i.years)).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"18-30 Age"
    json.selected false
    json.color		color
  elsif index == 2
    color	= "#85C1E9"
    json.y 				((@employee_list.where('date_of_birth > ? AND date_of_birth <= ?',(Date.today - 40.to_i.years),(Date.today - 30.to_i.years)).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"30-40 Age"
    json.selected false
    json.color		color
  elsif index == 3
    color	= "#73C6B6"
    json.y 				((@employee_list.where('date_of_birth > ? AND date_of_birth <= ?',(Date.today - 50.to_i.years),(Date.today - 40.to_i.years)).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"40-50 Age"
    json.selected false
    json.color		color
  elsif index == 4
    color	= "#F0B27A"
    json.y 				((@employee_list.where('date_of_birth > ? AND date_of_birth <= ?',(Date.today - 60.to_i.years),(Date.today - 50.to_i.years)).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"50-60 Age"
    json.selected false
    json.color		color
  elsif index == 5
    color	= "#BFC9CA"
    json.y 				((@employee_list.where('date_of_birth > ? AND date_of_birth <= ?',(Date.today - 70.to_i.years),(Date.today - 60.to_i.years)).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"60-70 Age"
    json.selected false
    json.color		color
  elsif index == 6
    color	= "#5D6D7E"
    json.y 				((@employee_list.where('date_of_birth > ? AND date_of_birth <= ?',(Date.today - 100.to_i.years),(Date.today - 70.to_i.years)).count).to_f/(@employee_list.count.to_f)*100).to_f.round(2)
    json.name			"70 and Above"
    json.selected false
    json.color		color
  end
end

service_tenure_data = []
service_tenure_data << @employee_list.where('joining_date >= ? AND joining_date <= ?',(Date.today - 2.to_i.years),(Date.today - 0.to_i.years)).count
service_tenure_data << @employee_list.where('joining_date > ? AND joining_date <= ?',(Date.today - 4.to_i.years),(Date.today - 2.to_i.years)).count
service_tenure_data << @employee_list.where('joining_date > ? AND joining_date <= ?',(Date.today - 6.to_i.years),(Date.today - 4.to_i.years)).count
service_tenure_data << @employee_list.where('joining_date > ? AND joining_date <= ?',(Date.today - 8.to_i.years),(Date.today - 6.to_i.years)).count
service_tenure_data << @employee_list.where('joining_date > ? AND joining_date <= ?',(Date.today - 10.to_i.years),(Date.today - 8.to_i.years)).count
service_tenure_data << @employee_list.where('joining_date > ? AND joining_date <= ?',(Date.today - 100.to_i.years),(Date.today - 10.to_i.years)).count

json.service_tenure_list 	["Below 2 Years", "2-4 Years", "4-6 Years", "6-8 Years", "8-10 Years", "Above 10 Years"]
json.service_tenure_data  service_tenure_data


senior_management_tier_list = []
senior_management_tier_data = []
middle_management_tier_list = []
middle_management_tier_data = []
junior_management_tier_list = []
junior_management_tier_data = []
non_management_tier_list = []
non_management_tier_data = []

json.senior_management_tier Grade.where(:id => @senior_management_tier).order('sort_order DESC').each do |grade|
  senior_management_tier_list << grade.name
  senior_management_tier_data << @employee_list.where(:grade_id => grade.id).count
end

json.middle_management_tier Grade.where(:id => @middle_management_tier).order('sort_order DESC').each do |grade|
  middle_management_tier_list << grade.name
  middle_management_tier_data << @employee_list.where(:grade_id => grade.id).count
end

json.junior_management_tier Grade.where(:id => @junior_management_tier).order('sort_order DESC').each do |grade|
  junior_management_tier_list << grade.name
  junior_management_tier_data << @employee_list.where(:grade_id => grade.id).count
end

json.non_management_tier Grade.where(:id => @non_management_tier).order('sort_order DESC').each do |grade|
  non_management_tier_list << grade.name
  non_management_tier_data << @employee_list.where(:grade_id => grade.id).count
end

json.senior_management_tier_list 	senior_management_tier_list
json.senior_management_tier_data 	senior_management_tier_data
json.middle_management_tier_list 	middle_management_tier_list
json.middle_management_tier_data 	middle_management_tier_data
json.junior_management_tier_list 	junior_management_tier_list
json.junior_management_tier_data 	junior_management_tier_data
json.non_management_tier_list 		non_management_tier_list
json.non_management_tier_data 		non_management_tier_data



prev_date = (Time.now - 6.month).to_date
month_name_list = []
month_name_data = []
joiner_list_data = []
leaver_list_data = []

Array.new(6).each_index do |index|
  new_prev_date = (prev_date + index.month).beginning_of_month
  new_curr_date = (prev_date + index.month).end_of_month
  month_name_list << new_prev_date.to_date.strftime("%B %Y")

  month_start_strength 	= @all_employee_list.where(['joining_date <= ?', (new_prev_date.to_date - 1.day).end_of_day]).count
  month_no_of_leaver		= EmployeeTransactionHistory.where(:employee_id => @all_employee_list.collect(&:id), :transaction_type => "End of Employment").where(['transaction_date <= ?', (new_prev_date.to_date - 1.day).end_of_day]).collect(&:employee_id).uniq.count
  month_end_strength		= @all_employee_list.where(['joining_date >= ? AND joining_date <= ?', new_prev_date, new_curr_date]).count
  joiner_list_data			<< month_end_strength

  puts "\n Month => #{(new_prev_date.to_date - 1.day).end_of_day} \n"
  puts "\n month_start_strength => #{month_start_strength} \n"
  puts "\n month_no_of_leaver => #{month_no_of_leaver} \n"
  puts "\n month_end_strength => #{month_end_strength} \n"

  month_start_strength 	= (month_start_strength - month_no_of_leaver)
  total_strength 				= (month_start_strength + (month_start_strength + month_end_strength)).to_f/2.0
  no_of_leaver					= EmployeeTransactionHistory.where(:employee_id => @all_employee_list.collect(&:id), :transaction_date => new_prev_date.to_date.beginning_of_day..new_curr_date.to_date.end_of_month.end_of_day, :transaction_type => "End of Employment").collect(&:employee_id).uniq.count
  leaver_list_data			<< no_of_leaver

  puts "\n start_strength => #{month_start_strength} \n"
  puts "\n total_strength => #{total_strength} \n"
  puts "\n no_of_leaver => #{no_of_leaver} \n"

  if no_of_leaver > 0
    month_name_data << ((no_of_leaver.to_f/total_strength.to_f)*100).to_f.round(2)
  else
    month_name_data << 0.0
  end
end

json.month_name_list 	month_name_list
json.month_name_data 	month_name_data
json.joiner_list_data 	joiner_list_data
json.leaver_list_data 	leaver_list_data
