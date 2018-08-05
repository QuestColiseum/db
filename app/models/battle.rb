class Battle
  include BaseModel

  symbolize :status, :in => [:team_one_victory, :team_two_victory, :created], :default => :created

  belongs_to :quest_level
  belongs_to :team_one, :class_name => "Team"
  belongs_to :team_two, :class_name => "Team"
  has_many :battle_teams

  has_many :turns
  has_many :battle_team_characters

  validates_presence_of :team_one, :team_two, :quest_level

  after_create :trigger_battle

  def trigger_battle
    battle_team_characters_init
    create_turn
  end

  def one_team_is_defeated
    self.battle_team_one.battle_team_characters.where(:is_dead => true).length == self.battle_team_one.battle_team_characters.length || self.battle_team_two.battle_team_characters.where(:is_dead => true).length == self.battle_team_two.battle_team_characters.length
  end

  def next_auto_trigger(battle_team)
    friendly_triggers = opposite_team(battle_team).battle_team_characters.select {|btc| btc.has_a_skill && btc.team_character.character.skill.friendly_auto_trigger == true && btc.has_full_mana == true}
    enemy_triggers = opposite_team(battle_team).battle_team_characters.select {|btc| btc.has_a_skill && btc.team_character.character.skill.enemy_auto_trigger == true && btc.has_full_mana == true}
    return_trigger_selection(friendly_triggers, enemy_triggers)
  end

  def return_trigger_selection(friendly_triggers, enemy_triggers)
    first_prio_trigger = (friendly_triggers + enemy_triggers).sort { |a, b| a.combined_speed <=> b.combined_speed }.first
    if first_prio_trigger.present?
      first_prio_trigger
    else
      false
    end
  end

  def next_skill_trigger(battle_team)
    friendly_triggers = battle_team.battle_team_characters.where(:has_full_mana => true).select {|btc| btc.team_character.character.friendly_skill_trigger == true}
    enemy_triggers = opposite_team(battle_team).battle_team_characters.where(:has_full_mana => true).select {|btc| btc.team_character.character.skill.enemy_skill_trigger == true}
    return_trigger_selection(friendly_triggers, enemy_triggers)
  end

  def opposite_team(battle_team)
    battle_team == battle_team_one ? battle_team_two : battle_team_one
  end

  def battle_team_one
    self.battle_teams.where(:team => self.team_one).first
  end

  def battle_team_two
    self.battle_teams.where(:team => self.team_two).first
  end

  def decide_winner
    self.reload.battle_team_characters.each { |c| puts "#{c.health} #{c.attack} #{c.armor} #{c.speed} #{c.team_character.character.name;}" }
    if self.battle_team_one.battle_team_characters.where(:is_dead => true).length == self.battle_team_one.battle_team_characters.length
      trigger_team_two_victory
    else
      trigger_team_one_victory
    end
  end

  def trigger_team_one_victory
    self.status = :team_one_victory
    self.save!
  end

  def trigger_team_two_victory
    self.status = :team_two_victory
    self.save!
  end

  def battle_team_characters_init
    def init_chars(team)
      battle_team = BattleTeam.create!(:team => team, :battle => self)
      team.team_characters.each do |team_character|
        BattleTeamCharacter.create!(:battle => self, :team_character => team_character, :battle_team => battle_team)
      end
    end
    init_chars(self.team_one)
    init_chars(self.team_two)
  end

  def create_turn
    Turn.create(:battle => self)
  end

end
