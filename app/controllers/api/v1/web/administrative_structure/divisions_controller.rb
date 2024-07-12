class Api::V1::Web::AdministrativeStructure::DivisionsController < ApplicationController

	before_action :set_division, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @divisions = Division.all.order('id DESC')
    render status:200, template: 'api/v1/web/administrative_structure/divisions/index'
  end

  def filter_data
    @divisions = Division.where(:state_id => params[:state_id]).order('id DESC')
    render status:200, template: 'api/v1/web/administrative_structure/divisions/index'
  end

  def create
    @division       = Division.new division_params
    if @division.save
      render json:{}, status: :created
    else
      render json: {errors: @division.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/administrative_structure/divisions/show'
  end

  def update
    if @division.update(division_params)
      render json: {}, status: 204
    else
      render json: {errors: @division.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @division.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @division.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def division_params
		params.permit(:country_id, :state_id, :name)
	end

  def set_division
    @division = Division.find(params[:id])
  end

end
