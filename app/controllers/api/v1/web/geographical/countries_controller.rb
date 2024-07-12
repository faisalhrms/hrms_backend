class Api::V1::Web::Geographical::CountriesController < ApplicationController

	before_action :set_country, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @countries = Country.all.order('id DESC')
    render status:200, template: 'api/v1/web/geographical/countries/index'
  end

  def show
    render status:200, template: 'api/v1/web/geographical/countries/show'
  end

	private

  def set_country
    @country = Country.find(params[:id])
  end

end
