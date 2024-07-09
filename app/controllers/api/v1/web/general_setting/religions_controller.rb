class Api::V1::Web::GeneralSetting::ReligionsController < ApplicationController

	before_filter :set_religion, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @religions = Religion.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/religions/index.json.jbuilder'
  end

  def create
    @religion       = Religion.new religion_params
    if @religion.save
      render json:{}, status: :created
    else
      render json: {errors: @religion.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/religions/show.json.jbuilder'
  end

  def update
    if @religion.update(religion_params)
      render json: {}, status: 204
    else
      render json: {errors: @religion.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @religion.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @religion.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def religion_params
		params.permit(:name)
	end

  def set_religion
    @religion = Religion.find(params[:id])
  end

end
