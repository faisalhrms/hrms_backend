class Api::V1::Web::EmployeeManagement::TemporaryStaffsController < ApplicationController

	before_filter :set_temporary_staff, :only => [:show, :update, :converted_to_employee, :download_temp_staff]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def temporary_staff_index
    @temporary_staffs = TemporaryStaff.where(:company_id => params[:company_id]).order('id DESC')
    if not params[:location_id].blank?
      @temporary_staffs = TemporaryStaff.location_related_employee(@temporary_staffs, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @temporary_staffs = TemporaryStaff.branch_related_employee(@temporary_staffs, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @temporary_staffs = TemporaryStaff.department_related_employee(@temporary_staffs, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @temporary_staffs = TemporaryStaff.designation_related_employee(@temporary_staffs, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @temporary_staffs = TemporaryStaff.job_title_related_employee(@temporary_staffs, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @temporary_staffs = TemporaryStaff.grade_related_employee(@temporary_staffs, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @temporary_staffs = TemporaryStaff.salary_unit_related_employee(@temporary_staffs, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @temporary_staffs = TemporaryStaff.cost_center_related_employee(@temporary_staffs, params[:cost_center_id].to_i)
    end
    render status:200, template: 'api/v1/web/employee_management/temporary_staffs/index.json.jbuilder'
  end

  def create
    @temporary_staff       = TemporaryStaff.new temporary_staff_params
    if params[:date_of_birth].nil?
    	@temporary_staff.date_of_birth = nil
    else
    	@temporary_staff.date_of_birth = params[:date_of_birth].to_date
    end
    if params[:joining_date].nil?
    	@temporary_staff.joining_date = nil
    else
    	@temporary_staff.joining_date = params[:joining_date].to_date
    end
    if @temporary_staff.save
      render json:{}, status: :created
    else
      render json: {errors: @temporary_staff.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/employee_management/temporary_staffs/show.json.jbuilder'
  end

  def converted_to_employee
    @temporary_staff.is_converted = true
    @temporary_staff.save
    @temporary_staff.make_employee
    render json: {}, status: 204
  end

  def update
  	if params[:date_of_birth].nil?
    	@temporary_staff.date_of_birth = nil
    else
    	@temporary_staff.date_of_birth = params[:date_of_birth].to_date
    end
    if params[:joining_date].nil?
    	@temporary_staff.joining_date = nil
    else
    	@temporary_staff.joining_date = params[:joining_date].to_date
    end
    if @temporary_staff.update(temporary_staff_params)
      render json: {}, status: 204
    else
      render json: {errors: @temporary_staff.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def download_temp_staff
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/employee_management/temporary_staffs/temp_staff_pdf_formats/temp_staff_info.pdf.erb"),
      :header => { content: render_to_string("api/v1/web/employee_management/temporary_staffs/temp_staff_pdf_formats/temp_staff_info_header.pdf.erb")},
      :margin => {
        :top      => '0.5in',
        :bottom   => '0.5in',
        :left     => '0.5in',
        :right    => '0.5in'
      },
      dpi: 200,
      disable_smart_shrinking: true
    )
    file_name = "#{@temporary_staff.full_name}_#{@temporary_staff.temporary_staff_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}, status: 200
  end

  def save_attendance
    temporary_staff = TemporaryStaff.find(params[:temporary_staff_id])
    date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
    if params[:attendance_list].present?
      attendance_list = params[:attendance_list]  
      Array.new(attendance_list.count).each_index do |index|
        if attendance_list[index.to_s][:temp_staff_attendance].present?
          temp_staff_attendance = TempStaffAttendance.find(attendance_list[index.to_s][:temp_staff_attendance_id])
          attendance_date = attendance_list[index.to_s][:attendance_date]
          temp_staff_attendance.attendance_status = attendance_list[index.to_s][:attendance_status]
          if attendance_list[index.to_s][:in_time].nil? or attendance_list[index.to_s][:in_time].blank?
            temp_staff_attendance.in_time = nil
          else
            check_in = attendance_list[index.to_s][:in_time]
            temp_staff_attendance.in_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, check_in.to_datetime.to_time.strftime('%H'), check_in.to_datetime.to_time.strftime('%M'), check_in.to_datetime.to_time.strftime('%S'))
          end
          if attendance_list[index.to_s][:out_time].nil? or attendance_list[index.to_s][:out_time].blank?
            temp_staff_attendance.out_time = nil
          else
            check_out = attendance_list[index.to_s][:out_time]
            temp_staff_attendance.out_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, check_out.to_datetime.to_time.strftime('%H'), check_out.to_datetime.to_time.strftime('%M'), check_out.to_datetime.to_time.strftime('%S'))
          end
          temp_staff_attendance.save
        else
          attendance_date = attendance_list[index.to_s][:attendance_date]
          temp_staff_attendance = TempStaffAttendance.new(:attendance_date => attendance_date.to_date, :in_time => nil, :out_time => nil)
          temp_staff_attendance.temporary_staff_id  = temporary_staff.id
          temp_staff_attendance.company_id          = temporary_staff.company_id
          temp_staff_attendance.attendance_status   = attendance_list[index.to_s][:attendance_status]
          if attendance_list[index.to_s][:in_time].nil? or attendance_list[index.to_s][:in_time].blank?
            temp_staff_attendance.in_time = nil
          else
            check_in = attendance_list[index.to_s][:in_time]
            temp_staff_attendance.in_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, check_in.to_datetime.to_time.strftime('%H'), check_in.to_datetime.to_time.strftime('%M'), check_in.to_datetime.to_time.strftime('%S'))
          end
          if attendance_list[index.to_s][:out_time].nil? or attendance_list[index.to_s][:out_time].blank?
            temp_staff_attendance.out_time = nil
          else
            check_out = attendance_list[index.to_s][:out_time]
            temp_staff_attendance.out_time = Time.new(attendance_date.to_datetime.year, attendance_date.to_datetime.month, attendance_date.to_datetime.day, check_out.to_datetime.to_time.strftime('%H'), check_out.to_datetime.to_time.strftime('%M'), check_out.to_datetime.to_time.strftime('%S'))
          end
          temp_staff_attendance.save
        end
      end
    end
    render json: {}, status: 204
  end

  def fetch_attendance
    @date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
    render status:200, template: 'api/v1/web/employee_management/temporary_staffs/fetch_attendance.json.jbuilder'
  end

	private

	def temporary_staff_params
		params.permit(:salutation, :first_name, :last_name, :father_name, :official_email, :official_mobile_number, :personal_email, :personal_number, :gender, :cnic_number, :blood_group, :martial_status, :gross_salary, :current_address, :company_id, :location_id, :branch_id, :department_id, :grade_id, :designation_id, :job_title_id, :salary_unit_id, :cost_center_id, :temporary_staff_code, :is_active, :current_address, :sub_department_id)
	end

  def set_temporary_staff
    @temporary_staff = TemporaryStaff.find(params[:id])
  end
end
