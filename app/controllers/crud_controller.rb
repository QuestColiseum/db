class CrudController < ApplicationController

  def index
    if params[:ids]
      objects = crud_class.where(:id.in => params[:ids])
    elsif params[:status]
      objects = crud_class.where(:status => params[:status])
    else
      objects = crud_class.all
    end
    render json: serialize_index_json_string(objects)
  end

  def show
    object = crud_class.find(params[:id])
    render json: serialize_single_json_string(object)
  end

  def create
    self.create_from_params
  end

  def update
    object = crud_class.find(params[:id])
    object.update_attributes(update_params)
    if object.errors.present?
      render json: { :errors => object.errors }, :status => :unprocessable_entity
    else
      render json: serialize_single_json_string(object)
    end
  end

  def destroy
    object = crud_class.find(params[:id])
    if object
      object.destroy
      head :no_content
    else
      head :not_found
    end
  end

protected
  def crud_class
    self.class.name.split('::').last.gsub('Controller', '').singularize.constantize
  end

  def create_from_params
    object = crud_class.create
    if object.errors.present?
      render json: { :errors => object.errors }, :status => :unprocessable_entity
    else
      render json: serialize_single_json_string(object)
    end
  end

  def serialize_index_json_string(objects)
    options = {}
    options[:meta] = { total: objects.length }
    options[:links] = {
      self: '...',
      next: '...',
      prev: '...'
    }
    BaseSerializer.new(objects, options).serialized_json
  end

  def serialize_single_json_string(object)
    BaseSerializer.new(object).serialized_json
  end
end
