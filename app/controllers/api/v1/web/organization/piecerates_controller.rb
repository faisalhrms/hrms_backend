class Api::V1::Web::Organization::PieceratesController < ApplicationController

  before_filter :set_piecerate, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @piecerates = Piecerate.all.order('piecerate_type_name ASC')
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def filter_data
    employee = Employee.where(:employee_code => params[:employee_code]).last
    @piecerates = []
    if employee.group_id.present?
      employee.group_id.split(",").each do |id|
        @piecerates << Piecerate.find(id.to_i)
      end
    end
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def department_related_data
    @piecerates = Piecerate.where(:department_id => params[:department_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def floor_data
    @piecerates = Piecerate.where(:piecerate_type_name => "floor").order('id DESC')
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def incharge_data
    @piecerates = Piecerate.where(:piecerate_type_name => "incharge").order('id DESC')
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def line_data
    @piecerates = Piecerate.where(:piecerate_type_name => "line").order('id DESC')
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def category_data
    @piecerates = Piecerate.where(:piecerate_type_name => "category").order('id DESC')
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def group_data
    @piecerates = Piecerate.where(:piecerate_type_name => "group").order('id DESC')
    render status:200, template: 'api/v1/web/organization/piecerates/index.json.jbuilder'
  end

  def create
    @piecerate       = Piecerate.new piecerate_params
    if @piecerate.save
      render json:{}, status: :created
    else
      render json: {errors: @piecerate.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/piecerates/show.json.jbuilder'
  end

  def update
    if @piecerate.update(piecerate_params)
      render json: {}, status: 204
    else
      render json: {errors: @piecerate.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @piecerate.destroy
      render json: {}, status: 204
    else
      render json: {errors: @piecerate.errors.full_messages}, status: :unprocessable_entity
    end
  end

  
  private

  def piecerate_params
    params.permit(:name, :total_machines,:piecerate_type_name, :floor_id, :line_id, :category_id)
  end

  def set_piecerate
    @piecerate = Piecerate.find(params[:id])
  end

end
