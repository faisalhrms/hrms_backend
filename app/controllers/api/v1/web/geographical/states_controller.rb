class Api::V1::Web::Geographical::StatesController < ApplicationController

	before_action :set_state, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @states = State.all.order('id DESC')
    render status:200, template: 'api/v1/web/geographical/states/index'
  end

  def filter_data
    @states = State.where(:country_id => params[:country_id]).order('id DESC')
    render status:200, template: 'api/v1/web/geographical/states/index'
  end

  def show
    render status:200, template: 'api/v1/web/geographical/states/show'
  end

	private

  def set_state
    @state = State.find(params[:id])
  end

end
