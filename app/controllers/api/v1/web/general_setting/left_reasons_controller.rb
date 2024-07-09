class Api::V1::Web::GeneralSetting::LeftReasonsController < ApplicationController

	before_filter :set_left_reason, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @left_reasons = LeftReason.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/left_reasons/index.json.jbuilder'
  end

  def active_list
    @left_reasons = LeftReason.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/left_reasons/index.json.jbuilder'
  end

  def create
    @left_reason       = LeftReason.new left_reason_params
    if @left_reason.save
      render json:{}, status: :created
    else
      render json: {errors: @left_reason.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/left_reasons/show.json.jbuilder'
  end

  def update
    if @left_reason.update(left_reason_params)
      render json: {}, status: 204
    else
      render json: {errors: @left_reason.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @left_reason.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @left_reason.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def left_reason_params
		params.permit(:name, :is_active, :description)
	end

  def set_left_reason
    @left_reason = LeftReason.find(params[:id])
  end

end
