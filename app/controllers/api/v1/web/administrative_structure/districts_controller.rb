class Api::V1::Web::AdministrativeStructure::DistrictsController < ApplicationController

	before_filter :set_district, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @districts = District.all.order('id DESC')
    render status:200, template: 'api/v1/web/administrative_structure/districts/index.json.jbuilder'
  end

  def filter_data
    @districts = District.where(:division_id => params[:division_id]).order('id DESC')
    render status:200, template: 'api/v1/web/administrative_structure/districts/index.json.jbuilder'
  end

  def create
    @district       = District.new district_params
    if @district.save
      render json:{}, status: :created
    else
      render json: {errors: @district.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/administrative_structure/districts/show.json.jbuilder'
  end

  def update
    if @district.update(district_params)
      render json: {}, status: 204
    else
      render json: {errors: @district.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @district.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @district.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def district_params
		params.permit(:division_id, :country_id, :state_id, :name)
	end

  def set_district
    @district = District.find(params[:id])
  end

end
