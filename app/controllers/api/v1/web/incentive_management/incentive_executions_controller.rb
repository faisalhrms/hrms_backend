class Api::V1::Web::IncentiveManagement::IncentiveExecutionsController < ApplicationController

	def incentive_employee_list
		selected_month 	= params[:selected_month].to_date
		start_date 			= params[:selected_month].to_date.beginning_of_month
		end_date 				= params[:selected_month].to_date.end_of_month
		employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :location_id => params[:location_id], :branch_id => params[:branch_id]).where('attendance_date::Date BETWEEN ? AND ?',start_date, end_date)
		employee_ids = employee_attendances.collect(&:employee_id).uniq
		@employees = Employee.where(:id => employee_ids, :incentive_allowed => true)
		render status:200, template: 'api/v1/web/employee_management/employees/index.json.jbuilder'
	end

	def sale_incentive
		selected_month 	= params[:selected_month].to_date
		start_date 			= params[:selected_month].to_date.beginning_of_month
		end_date 				= params[:selected_month].to_date.end_of_month
		company 	= Company.find(params[:company_id])
		location 	= Location.find(params[:location_id])
		branch = Branch.where(id: params[:branch_id]).collect(&:id)
		employee_attendances = EmployeeAttendance.where(:company_id => params[:company_id], :location_id => params[:location_id], :branch_id => params[:branch_id]).where('attendance_date::Date BETWEEN ? AND ?',start_date, end_date)
		EmployeeSaleIncentive.process_sale_incentive(employee_attendances, start_date, end_date, selected_month, company.id, location.id, branch)
		render json: {}, status: 204
		end

end
