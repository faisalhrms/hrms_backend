class Api::V1::Web::Geographical::CitiesController < ApplicationController

	before_action :set_city, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @cities = City.all.order('id DESC')
    render status:200, template: 'api/v1/web/geographical/cities/index'
  end

  def filter_data
    @cities = City.where(:state_id => params[:state_id]).order('id DESC')
    render status:200, template: 'api/v1/web/geographical/cities/index'
  end

  def show
    render status:200, template: 'api/v1/web/geographical/cities/show'
  end

	private

  def set_city
    @city = City.find(params[:id])
  end

end
