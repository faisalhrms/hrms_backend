class Api::V1::Web::GeneralSetting::QualificationProgramsController < ApplicationController

	before_filter :set_qualification_program, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @qualification_programs = QualificationProgram.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/qualification_programs/index.json.jbuilder'
  end

  def active_list
    @qualification_programs = QualificationProgram.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/qualification_programs/index.json.jbuilder'
  end

  def create
    @qualification_program       = QualificationProgram.new qualification_program_params
    if @qualification_program.save
      render json:{}, status: :created
    else
      render json: {errors: @qualification_program.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/qualification_programs/show.json.jbuilder'
  end

  def update
    if @qualification_program.update(qualification_program_params)
      render json: {}, status: 204
    else
      render json: {errors: @qualification_program.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @qualification_program.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @qualification_program.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def qualification_program_params
		params.permit(:name, :is_active, :description)
	end

  def set_qualification_program
    @qualification_program = QualificationProgram.find(params[:id])
  end

end
