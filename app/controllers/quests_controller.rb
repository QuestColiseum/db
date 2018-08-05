class QuestsController < CrudController

  def create_from_params
    object = crud_class.create(:stage => Stage.find_by(:name => "Forest"))
    if object.errors.present?
      render json: { :errors => object.errors }, :status => :unprocessable_entity
    else
      render json: serialize_single_json_string(object)
    end
  end

protected
  def serialize_index_json_string(objects)
    options = {}
    options[:meta] = { total: objects.length }
    options[:links] = {
      self: '...',
      next: '...',
      prev: '...'
    }
    QuestSerializer.new(objects, options).serialized_json
  end

  def serialize_single_json_string(object)
    QuestSerializer.new(object).serialized_json
  end

end
