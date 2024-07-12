class Api::V1::Web::GeneralSetting::RelationshipsController < ApplicationController

	before_action :set_relationship, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @relationships = Relationship.all.order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/relationships/index'
  end

  def active_list
    @relationships = Relationship.where(:is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/general_setting/relationships/index'
  end

  def create
    @relationship       = Relationship.new relationship_params
    if @relationship.save
      render json:{}, status: :created
    else
      render json: {errors: @relationship.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/general_setting/relationships/show'
  end

  def update
    if @relationship.update(relationship_params)
      render json: {}, status: 204
    else
      render json: {errors: @relationship.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @relationship.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @relationship.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def relationship_params
		params.permit(:name, :is_active, :description)
	end

  def set_relationship
    @relationship = Relationship.find(params[:id])
  end

end
