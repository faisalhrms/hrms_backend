class Api::V1::Web::GeneralSetting::GeneralTypesController < ApplicationController
  before_action :set_general_type, only: [:show, :edit, :update, :destroy]

  def index
    @general_types = GeneralType.hiring_shifts.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/general_types/index'
  end

  def show
  end

  def create
    @general_type = GeneralType.new(general_type_params)
    if @general_type.save
      render json:{}, status: :created
    else
      render json: {errors: @general_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @general_type.update(general_type_params)
      render json: {}, status: 204
    else
      render json: {errors: @general_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def filter_data
    @general_types = GeneralType.hiring_shifts.get_by_company(params[:company_id]).order('id DESC') # get all hiring shifts
    render status:200, template: 'api/v1/web/general_setting/general_types/index'
  end

  def destroy
    if Employee.get_by_hiring_shift(@general_type.id).exists?
      render json: {errors: 'Unable to remove. Employee with this record exist.'}, status: :unprocessable_entity
    else
      if @general_type.destroy
        render json: {}, status: 204
      else
        render json: {errors: @general_type.errors.full_messages}, status: :unprocessable_entity
      end
    end
  end

  private
    def set_general_type
      @general_type = GeneralType.find(params[:id])
    end

    def general_type_params
      params.permit(:name, :company_id, :description, :type_name)
    end
end
