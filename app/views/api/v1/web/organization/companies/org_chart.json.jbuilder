json.org_chart do
	json.name 	    @company.try(:name)
  json.title 	    @company.try(:code)
  json.office     "Company"
  json.children   @company.locations.where(:is_active => true).order('id ASC').each do |location|
  	json.name 	    location.try(:name)
  	json.title 	   location.try(:code)
    json.office     "Location"
  	json.children  location.branches.where(:is_active => true).order('id ASC').each do |branch|
	  	json.name 	   branch.try(:name)
	  	json.title 	    branch.try(:code)
      json.office     "Branch"
      json.children   branch.employees.active.order('id ASC').each do |employee|
        json.name       employee.full_name
        json.avatar     employee.try(:avatar).url
        json.title      employee.employee_code
        json.office     "Employee"
      end
	  end
  end
end