class QuestSerializer
  include FastJsonapi::ObjectSerializer
  set_id :_id
  has_one :party
  belongs_to :stage
  has_many :quest_levels
  attribute :current_quest_level do |quest|
    "#{quest.current_quest_level}"
  end
end
