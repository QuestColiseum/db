class GambitsController < CrudController

  def create
    self.create_from_params
  end
protected
  def create_from_params
    object = crud_class.create(
      :scenario => Scenario.find(params[:scenario_id]),
      :character => Character.find_by(:character_id => params[:character_id]),
      :status => params[:status].to_sym
    )
    if object.errors.present?
      render json: { :errors => object.errors }, :status => :unprocessable_entity
    else
      render json: serialize_single_json_string(object)
    end
  end

  def serialize_single_json_string(object)
    GambitSerializer.new(object).serialized_json
  end
end
