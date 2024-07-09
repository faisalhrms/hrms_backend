class Api::V1::Web::GeneralSetting::TrainingTypesController < ApplicationController

	before_filter :set_training_type, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @training_types = TrainingType.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/training_types/index.json.jbuilder'
  end

  def active_list
    @training_types = TrainingType.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/training_types/index.json.jbuilder'
  end

  def create
    @training_type       = TrainingType.new training_type_params
    if @training_type.save
      render json:{}, status: :created
    else
      render json: {errors: @training_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/training_types/show.json.jbuilder'
  end

  def update
    if @training_type.update(training_type_params)
      render json: {}, status: 204
    else
      render json: {errors: @training_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @training_type.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @training_type.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def training_type_params
		params.permit(:name, :is_active, :description)
	end

  def set_training_type
    @training_type = TrainingType.find(params[:id])
  end

end
