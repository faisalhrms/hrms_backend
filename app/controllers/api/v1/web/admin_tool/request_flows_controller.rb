class Api::V1::Web::AdminTool::RequestFlowsController < ApplicationController

	before_filter :set_request_flow, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @request_flows = RequestFlow.all.order('id DESC')
    else
      @request_flows = RequestFlow.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/request_flows/index.json.jbuilder'
  end

  def filter_data
    @request_flows = RequestFlow.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/request_flows/index.json.jbuilder'
  end

  def create
    @request_flow       = RequestFlow.new request_flow_params
    if @request_flow.save
      save_or_update_request_flow_detail
      render json:{}, status: :created
    else
      render json: {errors: @request_flow.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/request_flows/show.json.jbuilder'
  end

  def update
    if @request_flow.update(request_flow_params)
      save_or_update_request_flow_detail
      render json: {}, status: 204
    else
      render json: {errors: @request_flow.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @request_flow.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @request_flow.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_request_flow_detail
    request_flow_detail = RequestFlowDetail.find params[:request_flow_detail_id]
    request_flow_detail.destroy
    render json: {}, status: 204
  end

  private

	def request_flow_params
		params.permit(:company_id, :name, :request_flow_type, :request_node, :criteria, :back_date_limit, :back_date_apply)
	end

  def set_request_flow
    @request_flow = RequestFlow.find(params[:id])
  end

  def save_or_update_request_flow_detail
    ########## Request Flow Details ##########
    if params[:request_flow_details].present?
      request_flow_details = params[:request_flow_details]
      if request_flow_details.count > 0
        Array.new(request_flow_details.count).each_index do |index|
          if request_flow_details[index.to_s][:detail_id].nil?
            new_request_flow_detail                       = @request_flow.request_flow_details.build
            new_request_flow_detail.branch_id             = request_flow_details[index.to_s][:branch_id]
            new_request_flow_detail.department_id         = request_flow_details[index.to_s][:department_id]
            new_request_flow_detail.employee_id           = request_flow_details[index.to_s][:employee_id]
            new_request_flow_detail.request_node          = request_flow_details[index.to_s][:request_node]
            new_request_flow_detail.specific_condition    = request_flow_details[index.to_s][:specific_condition]
            new_request_flow_detail.save
          else
            edit_request_flow_detail                      = @request_flow.request_flow_details.find request_flow_details[index.to_s][:detail_id]
            edit_request_flow_detail.branch_id            = request_flow_details[index.to_s][:branch_id]
            edit_request_flow_detail.department_id        = request_flow_details[index.to_s][:department_id]
            edit_request_flow_detail.employee_id          = request_flow_details[index.to_s][:employee_id]
            edit_request_flow_detail.request_node         = request_flow_details[index.to_s][:request_node]
            edit_request_flow_detail.specific_condition   = request_flow_details[index.to_s][:specific_condition]
            edit_request_flow_detail.save
          end
        end
      end
    end
  end

end
