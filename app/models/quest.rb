class Quest
  include BaseModel
  symbolize :status, :in => [
    :created,
    :failed,
    :passed,
  ], :default => :created

  belongs_to :stage
  has_many :quest_levels
  has_one :party

  validates_presence_of :stage

  after_create :init_party
  after_create :init_first_quest_level

  def party_id
    self.party._id
  end

  def current_quest_level
    self.quest_levels.order('created_at desc').limit(1)[0]._id
  end

  def quest_level_ids
    self.quest_levels.sort_by {|ql| ql.level.number}.map {|ql| ql._id}
  end

  def init_party
    Party.create(:quest => self)
  end

  def init_first_quest_level
    QuestLevel.create(:quest => self, :level => Level.find_by(:stage => self.stage, :number => 1))
  end
end
