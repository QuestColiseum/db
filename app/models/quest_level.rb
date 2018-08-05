class QuestLevel
  include BaseModel

  belongs_to :quest
  belongs_to :level
  has_one :scenario
  has_one :battle

  symbolize :status, :in => [
    :created,
    :first_hero_gambit,
    :scenario_first_gambit,
    :scenario_second_gambit,
    :scenario_third_gambit,
    :scenario_fourth_gambit,
    :battle,
    :passed,
    :failed
  ], :default => :created

  after_create :offer_first_hero_scenario

  def scenario_id
    self.scenario._id
  end

  def trigger_check_status
    if self.status == :first_hero_gambit
      self.status = :scenario_first_gambit
    elsif self.status == :scenario_first_gambit
      if self.quest.party.gambit_per_scenario == :one
        self.status = :battle
        self.trigger_battle
      else
        self.status = :scenario_second_gambit
      end
    elsif self.status == :scenario_second_gambit
      if self.quest.party.gambit_per_scenario == :two
        self.status = :battle
        self.trigger_battle
      else
        self.status = :scenario_third_gambit
      end
    elsif self.status == :scenario_third_gambit
      if self.quest.party.gambit_per_scenario == :three
        self.status = :battle
        self.trigger_battle
      else
        self.status = :scenario_fourth_gambit
      end
    elsif self.status == :scenario_fourth_gambit
      self.status = :battle
      self.trigger_battle
    elsif self.status == :battle
      self.status = self.quest.battle.status == :team_one_victory ? :passed : :failed
    end
    self.save!
  end

  def trigger_battle
    Battle.create(:quest_level => self, :team_one => self.quest.party.team, :team_two => self.level.team)
  end

  def offer_first_hero_scenario
    if self.level.number == 1
      self.status = :first_hero_gambit
      self.save!
      Scenario.create!(:quest_level => self, :type => :first_hero_offer, :total_available_gambits => 2)
    else
      self.status = :scenario_first_gambit
      self.save!
      Scenario.create!(:quest_level => self)
    end
  end

end
