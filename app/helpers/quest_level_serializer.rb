class QuestLevelSerializer
  include FastJsonapi::ObjectSerializer
  set_id :_id
  belongs_to :quest
  belongs_to :level
  belongs_to :scenario
  attribute :status
end
