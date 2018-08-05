class ScenarioSerializer
  include FastJsonapi::ObjectSerializer
  set_id :_id
  attribute :status
  attribute :type
end
