class Api::V1::Web::GeneralSetting::ReligionSectsController < ApplicationController

	before_action :set_religion_sect, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @religion_sects = ReligionSect.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/religion_sects/index'
  end

  def create
    @religion_sect       = ReligionSect.new religion_sect_params
    if @religion_sect.save
      render json:{}, status: :created
    else
      render json: {errors: @religion_sect.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/religion_sects/show'
  end

  def update
    if @religion_sect.update(religion_sect_params)
      render json: {}, status: 204
    else
      render json: {errors: @religion_sect.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @religion_sect.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @religion_sect.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def religion_sect_params
		params.permit(:name)
	end

  def set_religion_sect
    @religion_sect = ReligionSect.find(params[:id])
  end

end
