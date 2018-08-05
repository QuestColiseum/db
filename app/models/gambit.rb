class Gambit
  include BaseModel

  symbolize :status, :in => [:upgrade, :recruit]
  field :is_final_gambit, :type => Boolean, :default => false
  has_one :team_character
  belongs_to :character
  belongs_to :scenario

  validates_presence_of :status
  validate :scenario_has_available_gambits

  after_create :add_team_character
  after_create :trigger_scenario_check_gambits

  def scenario_has_available_gambits
    errors.add(:base, "scenario is completed") if self.scenario.has_no_gambits_remaining
  end

  def trigger_scenario_check_gambits
    self.scenario.check_gambits
    if self.scenario.status == :completed
      self.is_final_gambit = true
      self.save!
    end
  end

  def add_team_character
    if self.status == :recruit
      TeamCharacter.create(:team => self.scenario.quest_level.quest.party.team, :character => self.character)
    end
  end

end
