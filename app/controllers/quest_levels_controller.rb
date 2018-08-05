class QuestLevelsController < CrudController

protected
  def serialize_single_json_string(object)
    QuestLevelSerializer.new(object).serialized_json
  end
end
