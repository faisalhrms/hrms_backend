class Api::V1::Web::Organization::JobTitlesController < ApplicationController

	before_filter :set_job_title, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @job_titles = JobTitle.all.order('id DESC')
    else
      @job_titles = JobTitle.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/job_titles/index.json.jbuilder'
  end

  def filter_data
    if current_user.is_admin == true or current_user.is_company_head == true
      @job_titles = JobTitle.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    else
      if current_user.employee.nil?
        @job_titles = JobTitle.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
      else
        @job_titles = JobTitle.where(:id => current_user.employee.job_title_id, :is_active => true).order('id DESC')
      end
    end
    render status:200, template: 'api/v1/web/organization/job_titles/index.json.jbuilder'
  end

  def create
    @job_title       = JobTitle.new job_title_params
    if @job_title.save
      render json:{}, status: :created
    else
      render json: {errors: @job_title.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/job_titles/show.json.jbuilder'
  end

  def update
    if @job_title.update(job_title_params)
      render json: {}, status: 204
    else
      render json: {errors: @job_title.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @job_title.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @job_title.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def job_title_params
		params.permit(:company_id, :name, :is_active, :description)
	end

  def set_job_title
    @job_title = JobTitle.find(params[:id])
  end

end
