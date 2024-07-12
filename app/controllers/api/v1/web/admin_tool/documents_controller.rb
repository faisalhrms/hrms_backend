class Api::V1::Web::AdminTool::DocumentsController < ApplicationController

	before_action :set_document, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @documents = Document.all.order('id DESC')
    else
      @documents = Document.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/documents/index'
  end

  def create
    @document       = Document.new document_params
    if @document.save
      render json:{:document_id => @document.id}, status: 200
    else
      render json: {errors: @document.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/documents/show'
  end

  def update
    if @document.update(document_params)
      render json:{:document_id => @document.id}, status: 200
    else
      render json: {errors: @document.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def upload_file
  	@document = Document.find(params[:document_id])
  	@document.avatar = params[:file]
  	@document.save
  	render json: {}, status: 204
  end

  def destroy
  	if @document.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @document.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def document_params
		params.permit(:company_id, :name, :code, :description, :avatar, :is_active)
	end

  def set_document
    @document = Document.find(params[:id])
  end

end
