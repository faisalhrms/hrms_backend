class Api::V1::Web::RosterManagement::RostersController < ApplicationController

	before_action :set_roster, :only => [:destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def roster_index
  	start_date 	= params[:start_date]
  	end_date 		= params[:end_date]
  	@date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date.strftime("%A -- %B %-d -- %Y")}
    @new_date_range   = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
  	@employee_rosters = EmployeeRoster.where(:company_id => params[:company_id], :roster_date => start_date.to_date..end_date.to_date).order('id DESC')
    employee_ids = @employee_rosters.pluck(:employee_id)
    @employees = Employee.where(:id => employee_ids).includes(:location, :branch, :department, :grade)
    filter_employee_roster_on_request
    @employee_roster_data = EmployeeRoster.group_by_employee(@new_date_range, @employees.ids)
    render status:200, template: 'api/v1/web/roster_management/rosters/index'
  end

  def export_roster
    start_date  = params[:start_date]
    end_date    = params[:end_date]
    @date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date.strftime("%A %B %-d %Y")}
    @employee_rosters = EmployeeRoster.where(:company_id => params[:company_id], :roster_date => start_date.to_date..end_date.to_date)
    employee_ids = @employee_rosters.collect(&:employee_id)
    @employees = Employee.where(:id => employee_ids)
    @employee_rosters = @employee_rosters.where(:employee_id => @employees.collect(&:id))
    filter_employee_roster_on_request
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Roster')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    if params[:report_type].to_i == 1
      header_row = []

      @date_range.each_index do |index|
        header_row << @date_range[index]
      end

      sheet.add_row header_row, :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      # Array.new(18).each_index do |index|
      #   sheet.column_info[index].width = 20
      # end
      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format 

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format 
        end
        
        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.hiring_shift
        current_row_style << row_format
        current_row_type << :string
        
        @date_range.each_index do |index|
          employee_roster = @employee_rosters.find_by(:employee_id => employee.id, :roster_date => @date_range[index].to_date)
          if employee_roster.nil?
            current_row_value << "No Roster"
            current_row_style << row_format
            current_row_type << :string
          else
            if employee_roster.is_rest_day == true
              current_row_value << "Rest Day"
              current_row_style << row_format
              current_row_type << :string
            end
            if employee_roster.is_rest_day == false
              flexi_shift = ""
              if employee_roster.is_flexi == true
                flexi_shift = "Flexi"
              else
                flexi_shift = ""
              end
              current_row_value << "#{employee_roster.time_slot_name} | #{employee_roster.formated_start_time} - #{employee_roster.formated_end_time} #{flexi_shift}" 
              current_row_style << row_format
              current_row_type << :string
            end
          end
        end
        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
    elsif params[:report_type].to_i == 2

      header_row = []
      header_row << "Sr #"
      header_row << "Emp Code"
      header_row << "Name"
      header_row << "Hiring Shift"
      header_row << "Work Shift"
      header_row << "Rest Day"
      header_row << "Date"
      header_row << "Timing"

      sheet.add_row header_row, :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      count = 0
      @employees.each do |employee|
        @employee_rosters.where(:employee_id => employee.id, :roster_date => start_date.to_date.beginning_of_day..end_date.to_date.end_of_day).order('roster_date ASC').each do |employee_roster|
          count = count + 1
          row_format = old_row_format 

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format 
          end
          
          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.hiring_shift
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_roster.time_slot_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.roster_rest_day_name(employee_roster)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee_roster.roster_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "#{employee_roster.formated_start_time} - #{employee_roster.formated_end_time}"
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
      end
    end
    location_name = ""
    if not params[:location_id].blank?
      location_name = Location.find(params[:location_id]).name
    end  
    file_name = "roster_export_#{location_name.downcase}"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def subordinate_roster_index
    start_date  = params[:start_date]
    end_date    = params[:end_date]
    @date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date.strftime("%A -- %B %-d -- %Y")}
    @new_date_range   = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
    @employee_rosters = EmployeeRoster.where(:company_id => params[:company_id], :roster_date => start_date.to_date..end_date.to_date).order('id DESC')
    if not current_user.employee.nil?
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
        @employees = @employees.where(:is_active => true)
        filter_employee_roster_on_request
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
        @employees = @employees.where(:is_active => true)
        filter_employee_roster_on_request
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
        @employees = @employees.where(:is_active => true)
        filter_employee_roster_on_request
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')
        @employees = @employees.where(:is_active => true)
        filter_employee_roster_on_request
      elsif current_user.is_sub_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id).order('id DESC')
        @employees = @employees.where(:is_active => true)
        filter_employee_roster_on_request
      elsif current_user.employee.is_line_manager == true
        employee_ids = Employee.where(:line_manager_id => current_user.employee.id).collect(&:id)
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids).order('id DESC')
        @employees = @employees.where(:is_active => true)
        filter_employee_roster_on_request
      else
        @employee_rosters = []
        @employees = []
      end
    else
      @employee_rosters = []
      @employees = []
    end
    @employee_roster_data = EmployeeRoster.group_by_employee(@new_date_range, @employees.ids)
    render status:200, template: 'api/v1/web/roster_management/rosters/index'
  end

  def generate_roster_detail
    ###################### Shift Dates ######################
    start_date 	= params[:start_date]
    end_date 		= params[:end_date]
    @date_range = []
    @complete_date_range = []
    monday 		= (Date.parse(start_date.to_date.strftime("%Y-%m-%d"))..Date.parse(end_date.to_date.strftime("%Y-%m-%d"))).select(&:monday?).map{|x| x.to_date}
    tuesday 	= (Date.parse(start_date.to_date.strftime("%Y-%m-%d"))..Date.parse(end_date.to_date.strftime("%Y-%m-%d"))).select(&:tuesday?).map{|x| x.to_date}
    wednesday = (Date.parse(start_date.to_date.strftime("%Y-%m-%d"))..Date.parse(end_date.to_date.strftime("%Y-%m-%d"))).select(&:wednesday?).map{|x| x.to_date}
    thursday 	= (Date.parse(start_date.to_date.strftime("%Y-%m-%d"))..Date.parse(end_date.to_date.strftime("%Y-%m-%d"))).select(&:thursday?).map{|x| x.to_date}
    friday 		= (Date.parse(start_date.to_date.strftime("%Y-%m-%d"))..Date.parse(end_date.to_date.strftime("%Y-%m-%d"))).select(&:friday?).map{|x| x.to_date}
    saturday 	= (Date.parse(start_date.to_date.strftime("%Y-%m-%d"))..Date.parse(end_date.to_date.strftime("%Y-%m-%d"))).select(&:saturday?).map{|x| x.to_date}
    sunday 		= (Date.parse(start_date.to_date.strftime("%Y-%m-%d"))..Date.parse(end_date.to_date.strftime("%Y-%m-%d"))).select(&:sunday?).map{|x| x.to_date}
    if params[:repeat] == "Every 2 Week"
      week_number = start_date.to_date.week_of_month
      selected_dates = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
      selected_dates.each_index do |index|
        if week_number % 2 == 0
          @complete_date_range << selected_dates[index]
          selected_value = EmployeeRoster.selected_day_verification(params[:day_selection], selected_dates[index])
          if not selected_value.nil?
            @date_range << selected_value
          end
        end
        if selected_dates[index].strftime("%A") == "Sunday"
          week_number = week_number + 1
        end
      end
      @date_range = @date_range.sort {|a,b| b <=> a}.reverse
      @date_range = @date_range.to_a.map{|x| x.to_date.strftime("%A, %B %-d, %Y")}
      @formated_date_range = @date_range.to_a.map{|x| x.to_date}
    else
      @date_range = @date_range + EmployeeRoster.repeat_every_week(params[:day_selection][:monday], monday)
      @date_range = @date_range + EmployeeRoster.repeat_every_week(params[:day_selection][:tuesday], tuesday)
      @date_range = @date_range + EmployeeRoster.repeat_every_week(params[:day_selection][:wednesday], wednesday)
      @date_range = @date_range + EmployeeRoster.repeat_every_week(params[:day_selection][:thursday], thursday)
      @date_range = @date_range + EmployeeRoster.repeat_every_week(params[:day_selection][:friday], friday)
      @date_range = @date_range + EmployeeRoster.repeat_every_week(params[:day_selection][:saturday], saturday)
      @date_range = @date_range + EmployeeRoster.repeat_every_week(params[:day_selection][:sunday], sunday)
      @date_range = @date_range.sort {|a,b| b <=> a}.reverse
      @date_range = @date_range.to_a.map{|x| x.to_date.strftime("%A, %B %-d, %Y")}
      @formated_date_range = @date_range.to_a.map{|x| x.to_date}
      @complete_date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
    end
    ###################### Employee List ######################
    if params[:employee_selection] == "complete_list"
      if current_user.is_admin == true
        @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
        filter_employee_on_request
      elsif current_user.is_company_head == true
        @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
        filter_employee_on_request
      elsif current_user.is_location_head == true
        @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
        filter_employee_on_request
      elsif current_user.is_department_head == true
        if not current_user.employee.nil?
          @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true, :department_id => current_user.employee.department_id).order('id DESC')
          filter_employee_on_request
        else
          @employees = []
        end
      elsif current_user.all_company_department == true
        if not current_user.employee.nil?
          @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :department_id => current_user.employee.department_id).order('id DESC')
          filter_employee_on_request
        else
          @employees = []
        end
      elsif not current_user.employee.nil?
        if current_user.employee.is_line_manager == true
          employee_ids = Employee.where(:line_manager_id => current_user.employee.id).collect(&:id)
          employee_ids << current_user.employee.id
          @employees = Employee.where(:id => employee_ids).order('id DESC')
        else
          @employees = []
        end
      else
        @employees = []
      end
    elsif params[:employee_selection] == "single_employee"
      @employees = Employee.where(:id => params[:employee_id], :is_active => true).order('id DESC')
    elsif params[:employee_selection] == "subordinate_employee"
      @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
      if not params[:department_id].blank?
        @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      end
      if not params[:grade_id].blank?
        @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
      end
      if current_user.is_sub_department_head == true
        @employees = @employees.where(:sub_department_id => current_user.employee.sub_department_id).order('id DESC')
      elsif not current_user.employee.nil?
        if current_user.employee.is_line_manager == true
          employee_ids = Employee.where(:line_manager_id => current_user.employee.id).collect(&:id)
          employee_ids << current_user.employee.id
          @employees = @employees.where(:id => employee_ids).order('id DESC')
        end
      end
    else
      @employees = []
    end
    @employees = @employees.get_by_employee_code(params[:employees].gsub(' ', '').split(',')) if params[:employees].present?
    @employees = @employees.get_by_hiring_shift(params[:hiring_shift_id]) if params[:hiring_shift_id].present?
    @employees = @employees.includes(:location, :branch, :department, :grade) if @employees.present?
    ###################### Time Slot ######################
    @time_slot = TimeSlot.find(params[:time_slot_id])
    render status:200, template: 'api/v1/web/roster_management/rosters/generate_roster_detail'
  end

  def generate_restday_roster_detail
    ###################### Shift Dates ######################
    @date_range = []
    @complete_date_range = []
    @formated_date_range = []

    if params[:new_restday_selected_date].present?
      if params[:new_restday_selected_date].count > 0
        new_restday_selected_date = params[:new_restday_selected_date]
        Array.new(new_restday_selected_date.count).each_index do |index|
          selected_date = new_restday_selected_date[index.to_s][:selected_date]
          @complete_date_range << selected_date.to_date
          @date_range << selected_date.to_date.strftime("%A, %B %-d, %Y")
          @formated_date_range << selected_date.to_date
        end
      end
    end

    if params[:new_bulk_restday_selected_date].present?
      if params[:new_bulk_restday_selected_date].count > 0
        new_bulk_restday_selected_date = params[:new_bulk_restday_selected_date]
        Array.new(new_bulk_restday_selected_date.count).each_index do |index|
          selected_date = new_bulk_restday_selected_date[index.to_s][:selected_date]
          @complete_date_range << selected_date.to_date
          @date_range << selected_date.to_date.strftime("%A, %B %-d, %Y")
          @formated_date_range << selected_date.to_date
        end
      end
    end
    
    ###################### Employee List ######################
    if params[:employee_selection] == "complete_list"
      if current_user.is_admin == true
        @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
        filter_employee_on_request
      elsif current_user.is_company_head == true
        @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
        filter_employee_on_request
      elsif current_user.is_location_head == true
        @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
        filter_employee_on_request
      elsif current_user.is_department_head == true
        if not current_user.employee.nil?
          @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true, :department_id => current_user.employee.department_id).order('id DESC')
          filter_employee_on_request
        else
          @employees = []
        end
      elsif current_user.all_company_department == true
        if not current_user.employee.nil?
          @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :department_id => current_user.employee.department_id).order('id DESC')
          filter_employee_on_request
        else
          @employees = []
        end
      elsif not current_user.employee.nil?
        if current_user.employee.is_line_manager == true
          employee_ids = Employee.where(:line_manager_id => current_user.employee.id).collect(&:id)
          employee_ids << current_user.employee.id
          @employees = Employee.where(:id => employee_ids).order('id DESC')
        else
          @employees = []
        end
      else
        @employees = []
      end
    elsif params[:employee_selection] == "single_employee"
      @employees = Employee.where(:id => params[:employee_id], :is_active => true).order('id DESC')
    elsif params[:employee_selection] == "subordinate_employee"
      @employees = Employee.where(:company_id => params[:company_id], :location_id => params[:location_id].to_i, :branch_id => params[:branch_id].to_i, :is_active => true).order('id DESC')
      if not params[:department_id].blank?
        @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      end
      if not params[:grade_id].blank?
        @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
      end
      if current_user.is_sub_department_head == true
        @employees = @employees.where(:sub_department_id => current_user.employee.sub_department_id).order('id DESC')  
      elsif not current_user.employee.nil?
        if current_user.employee.is_line_manager == true
          employee_ids = Employee.where(:line_manager_id => current_user.employee.id).collect(&:id)
          employee_ids << current_user.employee.id
          @employees = @employees.where(:id => employee_ids).order('id DESC')  
        end
      end
    else
      @employees = []
    end
    @employees = @employees.get_by_employee_code(params[:employees].gsub(' ', '').split(',')) if params[:employees].present?
    ###################### Time Slot ######################
    @time_slot = TimeSlot.find(params[:time_slot_id])
    render status:200, template: 'api/v1/web/roster_management/rosters/generate_restday_roster_detail'
  end

  def save_bulk_hiring_shift
    @employees = Employee.where(company_id: params[:company_id], location_id: params[:location_id])
    @employees = @employees.branch_related_employee(@employees, params[:branch_id]) if params[:branch_id].present?
    @employees = @employees.get_by_hiring_shift(params[:hiring_shift_id]) if params[:hiring_shift_id].present?
    @employees = @employees.department_related_employee(@employees, params[:department_id]) if params[:department_id].present?
    @employees = @employees.sub_department_related_employee(@employees, params[:sub_department_id]) if params[:sub_department_id].present?
    @employees = @employees.where(employee_code: params[:employees].gsub(' ', '').split(',')) if params[:employees].present?
    if @employees.present?
      is_saved = @employees.update_all(hiring_shift_id: params[:new_hiring_shift_id])
      if is_saved
        render json: {}, status: 204
      else
        render json: {errors: "Employees Not Saved"}, status: :unprocessable_entity
      end
    else
      render json: {errors: "Employees Not Found"}, status: :unprocessable_entity
    end
  end

  def save_single_restday
    time_slot = TimeSlot.find(params[:time_slot_id])
    if params[:roster_information].present?
      roster_information = params[:roster_information]
      if roster_information[:roster_list].present?
        roster_list = roster_information[:roster_list]
        Array.new(roster_list.count).each_index do |index|
          if roster_list[index.to_s][:roster_dates].present?
            roster_dates = roster_list[index.to_s][:roster_dates]
            Array.new(roster_dates.count).each_index do |nested_index|
              if roster_dates[nested_index.to_s][:already_exist] == "false"
                if roster_list[index.to_s][:is_selected] == "true"
                  employee_roster = EmployeeRoster.new
                  employee_roster.employee_id         = roster_list[index.to_s][:employee_id]
                  employee_roster.company_id          = roster_list[index.to_s][:company_id]
                  employee_roster.location_id         = roster_list[index.to_s][:location_id]
                  employee_roster.branch_id           = roster_list[index.to_s][:branch_id]
                  employee_roster.department_id       = roster_list[index.to_s][:department_id]
                  employee_roster.sub_department_id   = roster_list[index.to_s][:sub_department_id]
                  employee_roster.grade_id            = roster_list[index.to_s][:grade_id]
                  employee_roster.joining_date        = roster_list[index.to_s][:joining_date].to_date
                  employee_roster.roster_date         = roster_dates[nested_index.to_s][:date].to_date
                  employee_roster.employee_code       = roster_list[index.to_s][:employee_code]
                  employee_roster.employee_name       = roster_list[index.to_s][:employee_name]
                  employee_roster.location_name       = roster_list[index.to_s][:location_name]
                  employee_roster.branch_name         = roster_list[index.to_s][:branch_name]
                  employee_roster.department_name     = roster_list[index.to_s][:department_name]
                  employee_roster.grade_name          = roster_list[index.to_s][:grade_name]
                  employee_roster.is_rest_day         = true
                  employee_roster.time_slot_id        = time_slot.id
                  employee_roster.is_flexi            = time_slot.is_flexi
                  employee_roster.start_time          = time_slot.start_time
                  employee_roster.end_time            = time_slot.end_time
                  employee_roster.formated_start_time = time_slot.actual_start_time
                  employee_roster.formated_end_time   = time_slot.actual_end_time
                  employee_roster.start_buffer        = time_slot.start_buffer
                  employee_roster.end_buffer          = time_slot.end_buffer
                  employee_roster.save
                end
              elsif roster_dates[nested_index.to_s][:already_exist] == "true"
                if params[:over_right] == "true"
                  if roster_list[index.to_s][:is_selected] == "true"
                    employee_roster = EmployeeRoster.find(roster_dates[nested_index.to_s][:employee_roster_id])
                    if employee_roster.is_transfer == false and employee_roster.is_edited == false
                      employee_roster.employee_id         = roster_list[index.to_s][:employee_id]
                      employee_roster.company_id          = roster_list[index.to_s][:company_id]
                      employee_roster.location_id         = roster_list[index.to_s][:location_id]
                      employee_roster.branch_id           = roster_list[index.to_s][:branch_id]
                      employee_roster.department_id       = roster_list[index.to_s][:department_id]
                      employee_roster.sub_department_id   = roster_list[index.to_s][:sub_department_id]
                      employee_roster.grade_id            = roster_list[index.to_s][:grade_id]
                      employee_roster.joining_date        = roster_list[index.to_s][:joining_date].to_date
                      employee_roster.roster_date         = roster_dates[nested_index.to_s][:date].to_date
                      employee_roster.employee_code       = roster_list[index.to_s][:employee_code]
                      employee_roster.employee_name       = roster_list[index.to_s][:employee_name]
                      employee_roster.location_name       = roster_list[index.to_s][:location_name]
                      employee_roster.branch_name         = roster_list[index.to_s][:branch_name]
                      employee_roster.department_name     = roster_list[index.to_s][:department_name]
                      employee_roster.grade_name          = roster_list[index.to_s][:grade_name]
                      employee_roster.is_rest_day         = true
                      employee_roster.time_slot_id        = time_slot.id
                      employee_roster.is_flexi            = time_slot.is_flexi
                      employee_roster.start_time          = time_slot.start_time
                      employee_roster.end_time            = time_slot.end_time
                      employee_roster.formated_start_time = time_slot.actual_start_time
                      employee_roster.formated_end_time   = time_slot.actual_end_time
                      employee_roster.start_buffer        = time_slot.start_buffer
                      employee_roster.end_buffer          = time_slot.end_buffer
                      remove_duplication(employee_roster)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    render json: {}, status: 204
  end

  def create
    repeat = ''
    case params[:repeat]
    when 'Every Week'
      repeat = 1.week
    when 'Every 2 Week'
      repeat = 2.week
    when 'Monthly'
      repeat = 1.month
    end
    next_change =  params[:start_date].to_date + repeat if repeat.present?
    time_slot_ids = [params[:time_slot_id].to_i]
    time_slot_ids << params[:time_slot_id_1].to_i if params[:time_slot_id_1].present?
    time_slot_ids << params[:time_slot_id_2].to_i if params[:time_slot_id_2].present?

    time_slot_index = 0
    time_slot = TimeSlot.find(params[:time_slot_id])
    bulk_insert = []
    bulk_update = []
    if params[:roster_information].present?
    	roster_information = params[:roster_information]
    	if roster_information[:roster_list].present?
    		roster_list = roster_information[:roster_list]
    		Array.new(roster_list.count).each_index do |index|
    			if roster_list[index.to_s][:roster_dates].present?
    				roster_dates = roster_list[index.to_s][:roster_dates]
    				Array.new(roster_dates.count).each_index do |nested_index|
							if roster_dates[nested_index.to_s][:already_exist] == "false"
                if roster_list[index.to_s][:is_selected] == "true"
                  if params[:repeat].present?
                    if next_change == roster_dates[nested_index.to_s][:date].to_date
                      if time_slot_index == (time_slot_ids.length - 1)
                        time_slot_index = 0
                      else
                        time_slot_index = time_slot_index + 1
                      end
                      next_change = next_change + repeat
                    end
                    time_slot = TimeSlot.find(time_slot_ids[time_slot_index])
                  end
                  bulk_insert << save_single_roster(EmployeeRoster.new, roster_list, roster_dates, time_slot, index, nested_index, roster_dates[nested_index.to_s][:date].to_date)
                end
							elsif roster_dates[nested_index.to_s][:already_exist] == "true"
                if params[:over_right] == "true"
                  if roster_list[index.to_s][:is_selected] == "true"
                    employee_roster = EmployeeRoster.find(roster_dates[nested_index.to_s][:employee_roster_id])
                    if employee_roster.is_transfer == false and employee_roster.is_edited == false
                      if params[:repeat].present?
                        if next_change == roster_dates[nested_index.to_s][:date].to_date
                          if time_slot_index == (time_slot_ids.length - 1)
                            time_slot_index = 0
                          else
                            time_slot_index = time_slot_index + 1
                          end
                          next_change = next_change + repeat
                        end
                        time_slot = TimeSlot.find(time_slot_ids[time_slot_index])
                      end
                      bulk_update << save_single_roster(employee_roster, roster_list, roster_dates, time_slot, index, nested_index, roster_dates[nested_index.to_s][:date].to_date)
                    end
                  end
                end
              end
    				end
          end
          time_slot_index = 0
          next_change =  params[:start_date].to_date + repeat if repeat.present?
        end
      end
      if bulk_insert.present?
        EmployeeRoster.import(bulk_insert, batch_size: 300, validate_uniqueness: true)
      end
      if bulk_update.present?
        columns = [:employee_id, :company_id, :location_id, :branch_id, :department_id, :sub_department_id, :grade_id, :joining_date, :roster_date, :employee_code, :employee_name,
                   :location_name, :branch_name, :department_name, :grade_name, :is_rest_day, :time_slot_id, :is_flexi, :start_time, :end_time, :formated_start_time, :formated_end_time,
                   :start_buffer, :end_buffer]
        EmployeeRoster.import bulk_update, on_duplicate_key_update: {conflict_target: [:id], columns: columns}
      end
    end
    render json: {}, status: 204
  end

  def save_roster_rest_day
    time_slot = TimeSlot.find(params[:time_slot_id])
    if params[:roster_information].present?
      roster_information = params[:roster_information]
      if roster_information[:roster_list].present?
        roster_list = roster_information[:roster_list]
        Array.new(roster_list.count).each_index do |index|
          if roster_list[index.to_s][:roster_dates].present?
            roster_dates = roster_list[index.to_s][:roster_dates]
            Array.new(roster_dates.count).each_index do |nested_index|
              if roster_dates[nested_index.to_s][:already_exist] == "false"
                if roster_list[index.to_s][:is_selected] == "true"
                  if roster_dates[nested_index.to_s][:is_rest_day] == "false"
                    employee_roster = EmployeeRoster.new
                    employee_roster.employee_id         = roster_list[index.to_s][:employee_id]
                    employee_roster.company_id          = roster_list[index.to_s][:company_id]
                    employee_roster.location_id         = roster_list[index.to_s][:location_id]
                    employee_roster.branch_id           = roster_list[index.to_s][:branch_id]
                    employee_roster.department_id       = roster_list[index.to_s][:department_id]
                    employee_roster.sub_department_id   = roster_list[index.to_s][:sub_department_id]
                    employee_roster.grade_id            = roster_list[index.to_s][:grade_id]
                    employee_roster.joining_date        = roster_list[index.to_s][:joining_date].to_date
                    employee_roster.roster_date         = roster_dates[nested_index.to_s][:date].to_date
                    employee_roster.employee_code       = roster_list[index.to_s][:employee_code]
                    employee_roster.employee_name       = roster_list[index.to_s][:employee_name]
                    employee_roster.location_name       = roster_list[index.to_s][:location_name]
                    employee_roster.branch_name         = roster_list[index.to_s][:branch_name]
                    employee_roster.department_name     = roster_list[index.to_s][:department_name]
                    employee_roster.grade_name          = roster_list[index.to_s][:grade_name]
                    employee_roster.is_rest_day         = true
                    employee_roster.time_slot_id        = time_slot.id
                    employee_roster.is_flexi            = time_slot.is_flexi
                    employee_roster.start_time          = time_slot.start_time
                    employee_roster.end_time            = time_slot.end_time
                    employee_roster.formated_start_time = time_slot.actual_start_time
                    employee_roster.formated_end_time   = time_slot.actual_end_time
                    employee_roster.start_buffer        = time_slot.start_buffer
                    employee_roster.end_buffer          = time_slot.end_buffer
                    employee_roster.save
                  end
                end
              elsif roster_dates[nested_index.to_s][:already_exist] == "true"
                if params[:over_right] == "true"
                  if roster_list[index.to_s][:is_selected] == "true"
                    employee_roster = EmployeeRoster.find(roster_dates[nested_index.to_s][:employee_roster_id])
                    if employee_roster.is_transfer == false and employee_roster.is_edited == false
                      if roster_dates[nested_index.to_s][:is_rest_day] == "false"
                        employee_roster.employee_id         = roster_list[index.to_s][:employee_id]
                        employee_roster.company_id          = roster_list[index.to_s][:company_id]
                        employee_roster.location_id         = roster_list[index.to_s][:location_id]
                        employee_roster.branch_id           = roster_list[index.to_s][:branch_id]
                        employee_roster.department_id       = roster_list[index.to_s][:department_id]
                        employee_roster.sub_department_id   = roster_list[index.to_s][:sub_department_id]
                        employee_roster.grade_id            = roster_list[index.to_s][:grade_id]
                        employee_roster.joining_date        = roster_list[index.to_s][:joining_date].to_date
                        employee_roster.roster_date         = roster_dates[nested_index.to_s][:date].to_date
                        employee_roster.employee_code       = roster_list[index.to_s][:employee_code]
                        employee_roster.employee_name       = roster_list[index.to_s][:employee_name]
                        employee_roster.location_name       = roster_list[index.to_s][:location_name]
                        employee_roster.branch_name         = roster_list[index.to_s][:branch_name]
                        employee_roster.department_name     = roster_list[index.to_s][:department_name]
                        employee_roster.grade_name          = roster_list[index.to_s][:grade_name]
                        employee_roster.is_rest_day         = true
                        employee_roster.time_slot_id        = time_slot.id
                        employee_roster.is_flexi            = time_slot.is_flexi
                        employee_roster.start_time          = time_slot.start_time
                        employee_roster.end_time            = time_slot.end_time
                        employee_roster.formated_start_time = time_slot.actual_start_time
                        employee_roster.formated_end_time   = time_slot.actual_end_time
                        employee_roster.start_buffer        = time_slot.start_buffer
                        employee_roster.end_buffer          = time_slot.end_buffer
                        employee_roster.save
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    render json: {}, status: 204
  end

  def single_update
    is_flexi    = params[:is_flexi]
    is_rest_day = params[:is_rest_day]
    time_slot = TimeSlot.find(params[:time_slot_id])
    if params[:employee_roster_id].present?
      employee_roster = EmployeeRoster.find(params[:employee_roster_id])
      if employee_roster.is_transfer == false
        employee_roster.is_rest_day         = is_rest_day
        employee_roster.time_slot_id        = time_slot.id
        if is_flexi == "true"
          employee_roster.is_flexi          = true
        else
          employee_roster.is_flexi          = time_slot.is_flexi
        end
        employee_roster.start_time          = time_slot.start_time
        employee_roster.end_time            = time_slot.end_time
        employee_roster.formated_start_time = time_slot.actual_start_time
        employee_roster.formated_end_time   = time_slot.actual_end_time
        employee_roster.start_buffer        = time_slot.start_buffer
        employee_roster.end_buffer          = time_slot.end_buffer
        employee_roster.is_edited           = true
        employee_roster.save
      end
    else
      employee_roster = EmployeeRoster.new
      employee_roster.employee_id         = params[:employee_id]
      employee_roster.company_id          = params[:company_id]
      employee_roster.location_id         = params[:location_id]
      employee_roster.branch_id           = params[:branch_id]
      employee_roster.department_id       = params[:department_id]
      employee_roster.sub_department_id   = params[:sub_department_id]
      employee_roster.grade_id            = params[:grade_id]
      employee_roster.joining_date        = params[:joining_date].to_date
      employee_roster.roster_date         = params[:selected_date].to_date
      employee_roster.employee_code       = params[:employee_code]
      employee_roster.employee_name       = params[:employee_name]
      employee_roster.location_name       = params[:location_name]
      employee_roster.branch_name         = params[:branch_name]
      employee_roster.department_name     = params[:department_name]
      employee_roster.grade_name          = params[:grade_name]
      employee_roster.is_rest_day         = is_rest_day
      employee_roster.time_slot_id        = time_slot.id
      if is_flexi == "true"
        employee_roster.is_flexi          = true
      else
        employee_roster.is_flexi          = time_slot.is_flexi
      end
      employee_roster.start_time          = time_slot.start_time
      employee_roster.end_time            = time_slot.end_time
      employee_roster.formated_start_time = time_slot.actual_start_time
      employee_roster.formated_end_time   = time_slot.actual_end_time
      employee_roster.start_buffer        = time_slot.start_buffer
      employee_roster.end_buffer          = time_slot.end_buffer
      employee_roster.is_edited           = true
      employee_roster.save
    end
    render json: {}, status: 204
  end

  def show
    @employee    = Employee.find params[:employee_id]
    @time_slots = TimeSlot.where(:branch_id => @employee.branch_id, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/roster_management/rosters/show'
  end

  def get_employee_roster
    month_start_date   = (Time.now - 1.month).beginning_of_month
    month_end_date     = (Time.now + 1.month).end_of_month
    @employee_rosters = EmployeeRoster.where(:employee_id => params[:employee_id], :roster_date =>month_start_date.to_date..month_end_date.to_date).order('roster_date ASC')
    render status:200, template: 'api/v1/web/roster_management/rosters/get_employee_roster'
  end

  def bulk_update
    is_flexi    = params[:is_flexi]
    is_rest_day = params[:is_rest_day]
    time_slot = TimeSlot.find(params[:time_slot_id])
    if params[:roster_information].present?
      roster_information = params[:roster_information]
      if roster_information[:employee_rosters].present?
        employee_rosters = roster_information[:employee_rosters]
        Array.new(employee_rosters.count).each_index do |index|
          if employee_rosters[index.to_s][:roster_detail].present?
            if employee_rosters[index.to_s][:is_active] == "true"
              if employee_rosters[index.to_s][:roster_detail][:employee_roster_id].present?
                employee_roster = EmployeeRoster.find(employee_rosters[index.to_s][:roster_detail][:employee_roster_id])
                if employee_roster.is_transfer == false
                  employee_roster.company_id          = employee_rosters[index.to_s][:company_id]
                  employee_roster.location_id         = employee_rosters[index.to_s][:location_id]
                  employee_roster.branch_id           = employee_rosters[index.to_s][:branch_id]
                  employee_roster.department_id       = employee_rosters[index.to_s][:department_id]
                  employee_roster.sub_department_id   = employee_rosters[index.to_s][:sub_department_id]
                  employee_roster.grade_id            = employee_rosters[index.to_s][:grade_id]
                  employee_roster.is_rest_day         = is_rest_day
                  employee_roster.time_slot_id        = time_slot.id
                  if is_flexi == "true"
                    employee_roster.is_flexi          = true
                  else
                    employee_roster.is_flexi          = time_slot.is_flexi
                  end
                  employee_roster.start_time          = time_slot.start_time
                  employee_roster.end_time            = time_slot.end_time
                  employee_roster.formated_start_time = time_slot.actual_start_time
                  employee_roster.formated_end_time   = time_slot.actual_end_time
                  employee_roster.start_buffer        = time_slot.start_buffer
                  employee_roster.end_buffer          = time_slot.end_buffer
                  employee_roster.is_edited           = true
                  employee_roster.save
                end
              else
                employee_roster = EmployeeRoster.new
                employee_roster.employee_id         = employee_rosters[index.to_s][:employee_id]
                employee_roster.company_id          = employee_rosters[index.to_s][:company_id]
                employee_roster.location_id         = employee_rosters[index.to_s][:location_id]
                employee_roster.branch_id           = employee_rosters[index.to_s][:branch_id]
                employee_roster.department_id       = employee_rosters[index.to_s][:department_id]
                employee_roster.sub_department_id   = employee_rosters[index.to_s][:sub_department_id]
                employee_roster.grade_id            = employee_rosters[index.to_s][:grade_id]
                employee_roster.joining_date        = employee_rosters[index.to_s][:joining_date].to_date
                employee_roster.roster_date         = employee_rosters[index.to_s][:roster_detail][:roster_date].to_date
                employee_roster.employee_code       = employee_rosters[index.to_s][:employee_code]
                employee_roster.employee_name       = employee_rosters[index.to_s][:employee_name]
                employee_roster.location_name       = employee_rosters[index.to_s][:location_name]
                employee_roster.branch_name         = employee_rosters[index.to_s][:branch_name]
                employee_roster.department_name     = employee_rosters[index.to_s][:department_name]
                employee_roster.grade_name          = employee_rosters[index.to_s][:grade_name]
                employee_roster.is_rest_day         = is_rest_day
                employee_roster.time_slot_id        = time_slot.id
                if is_flexi == "true"
                  employee_roster.is_flexi          = true
                else
                  employee_roster.is_flexi          = time_slot.is_flexi
                end
                employee_roster.start_time          = time_slot.start_time
                employee_roster.end_time            = time_slot.end_time
                employee_roster.formated_start_time = time_slot.actual_start_time
                employee_roster.formated_end_time   = time_slot.actual_end_time
                employee_roster.start_buffer        = time_slot.start_buffer
                employee_roster.end_buffer          = time_slot.end_buffer
                employee_roster.is_edited           = true
                employee_roster.save
              end
            end
          end
        end
      end
    end
    render json: {}, status: 204
  end

  def bulk_deletion
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    EmployeeRoster.where(:company_id => params[:company_id].to_i, :employee_id => params[:employee_id].to_i, :roster_date => start_date.to_date.beginning_of_day..end_date.to_date.end_of_day).each do |employee_roster|
      if employee_roster.is_transfer == false and employee_roster.is_edited == false
        employee_roster.destroy
      end
    end
    render json: {}, status: 204
  end

  def destroy
    if @roster.is_transfer == false
    	if @roster.destroy
    		render json: {}, status: 204
    	else
    		render json: {errors: @roster.errors.full_messages}, status: :unprocessable_entity
    	end
    else
      render json: {errors: "Transfer Employee Can't Deleted"}, status: :unprocessable_entity
    end
  end

  def bulk_destroy
    if params[:roster_information].present?
      roster_information = params[:roster_information]
      if roster_information[:employee_rosters].present?
        employee_rosters = roster_information[:employee_rosters]
        Array.new(employee_rosters.count).each_index do |index|
          if employee_rosters[index.to_s][:roster_detail].present?
            if employee_rosters[index.to_s][:is_active] == "true"
              if employee_rosters[index.to_s][:roster_detail][:employee_roster_id].present?
                employee_roster = EmployeeRoster.find(employee_rosters[index.to_s][:roster_detail][:employee_roster_id])
                if employee_roster.is_transfer == false
                  employee_roster.destroy
                end
              end
            end
          end
        end
      end
    end
    render json: {}, status: 204
  end

	private

  def save_single_roster(employee_roster, roster_list, roster_dates, time_slot, index, nested_index, roster_date, repeat_no = 0 )
    employee_roster.employee_id         = roster_list[index.to_s][:employee_id]
    employee_roster.company_id          = roster_list[index.to_s][:company_id]
    employee_roster.location_id         = roster_list[index.to_s][:location_id]
    employee_roster.branch_id           = roster_list[index.to_s][:branch_id]
    employee_roster.department_id       = roster_list[index.to_s][:department_id]
    employee_roster.sub_department_id   = roster_list[index.to_s][:sub_department_id]
    employee_roster.grade_id            = roster_list[index.to_s][:grade_id]
    employee_roster.joining_date        = roster_list[index.to_s][:joining_date].to_date
    employee_roster.roster_date         = roster_date
    employee_roster.employee_code       = roster_list[index.to_s][:employee_code]
    employee_roster.employee_name       = roster_list[index.to_s][:employee_name]
    employee_roster.location_name       = roster_list[index.to_s][:location_name]
    employee_roster.branch_name         = roster_list[index.to_s][:branch_name]
    employee_roster.department_name     = roster_list[index.to_s][:department_name]
    employee_roster.grade_name          = roster_list[index.to_s][:grade_name]
    employee_roster.is_rest_day         = roster_dates[nested_index.to_s][:is_rest_day]
    employee_roster.time_slot_id        = time_slot.id
    employee_roster.is_flexi            = time_slot.is_flexi
    employee_roster.start_time          = time_slot.start_time
    employee_roster.end_time            = time_slot.end_time
    employee_roster.formated_start_time = time_slot.actual_start_time
    employee_roster.formated_end_time   = time_slot.actual_end_time
    employee_roster.start_buffer        = time_slot.start_buffer
    employee_roster.end_buffer          = time_slot.end_buffer
    employee_roster
  end

  def set_roster
    @roster = EmployeeRoster.find(params[:id])
  end

  def filter_employee_roster_on_request
    if not params[:location_id].blank?
      @employee_rosters = EmployeeRoster.location_related_employee_roster(@employee_rosters, params[:location_id].to_i)
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employee_rosters = EmployeeRoster.branch_related_employee_roster(@employee_rosters, params[:branch_id].to_i)
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employee_rosters = EmployeeRoster.department_related_employee_roster(@employee_rosters, params[:department_id].to_i)
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      unless params[:sub_department_id].blank?
        @employee_rosters = EmployeeRoster.sub_department_related_employee_roster(@employee_rosters, params[:sub_department_id].to_i)
        @employees = Employee.sub_department_related_employee(@employees, params[:sub_department_id].to_i)
      end
    end
    if not params[:grade_id].blank?
      @employee_rosters = EmployeeRoster.grade_related_employee_roster(@employee_rosters, params[:grade_id].to_i)
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
    @employees = @employees.get_by_hiring_shift(params[:hiring_shift_id]) if params[:hiring_shift_id].present?
  end

  def filter_employee_on_request
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      unless params[:sub_department_id].blank?
        @employees = Employee.sub_department_related_employee(@employees, params[:sub_department_id].to_i)
      end
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

  def delete_pdf_reports
    files = Dir.glob(File.join("#{Rails.public_path}/pdf", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def delete_excel_reports
    files = Dir.glob(File.join("#{Rails.public_path}/excel", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def remove_duplication(exiting_shift_assignment)
    all_ids = EmployeeRoster.where(employee_id: exiting_shift_assignment.employee_id, roster_date: exiting_shift_assignment.roster_date).ids
    EmployeeRoster.where(id: all_ids - [exiting_shift_assignment.id]).destroy_all if(all_ids.count >= 2)
    exiting_shift_assignment.save
  end

end
