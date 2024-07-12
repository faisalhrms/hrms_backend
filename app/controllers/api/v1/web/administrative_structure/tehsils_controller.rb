class Api::V1::Web::AdministrativeStructure::TehsilsController < ApplicationController

	before_action :set_tehsil, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @tehsils = Tehsil.all.order('id DESC')
    render status:200, template: 'api/v1/web/administrative_structure/tehsils/index'
  end

  def filter_data
    @tehsils = Tehsil.where(:district_id => params[:district_id]).order('id DESC')
    render status:200, template: 'api/v1/web/administrative_structure/tehsils/index'
  end

  def create
    @tehsil       = Tehsil.new tehsil_params
    if @tehsil.save
      render json:{}, status: :created
    else
      render json: {errors: @tehsil.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/administrative_structure/tehsils/show'
  end

  def update
    if @tehsil.update(tehsil_params)
      render json: {}, status: 204
    else
      render json: {errors: @tehsil.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @tehsil.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @tehsil.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def tehsil_params
		params.permit(:division_id, :district_id, :country_id, :state_id, :name)
	end

  def set_tehsil
    @tehsil = Tehsil.find(params[:id])
  end

end
