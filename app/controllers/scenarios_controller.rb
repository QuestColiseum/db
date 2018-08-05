class ScenariosController < CrudController

protected
  def serialize_single_json_string(object)
    ScenarioSerializer.new(object).serialized_json
  end
end
