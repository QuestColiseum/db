class BattleTeamCharacter
  include BaseModel

  belongs_to :battle
  belongs_to :team_character
  belongs_to :battle_team

  field :is_dead, :type => Boolean, :default => false
  field :is_poisoned, :type => Boolean, :default => false
  field :is_silenced, :type => Boolean, :default => false
  field :is_stunned, :type => Boolean, :default => false
  field :is_hidden, :type => Boolean, :default => false
  field :has_moved_for_turn, :type => Boolean, :default => false

  field :poison_turn_counter, :type => Float, :default => 0
  field :silence_turn_counter, :type => Float, :default => 0

  symbolize :auto_type, :in => [:ranged, :melee], :default => :melee
  field :mana_cost, :type => Float, :default => 0
  field :mana_available, :type => Float, :default => 0
  field :health, :type => Float, :default => 0
  field :speed, :type => Float, :default => 0
  field :attack, :type => Float, :default => 0
  field :armor, :type => Float, :default => 0
  field :bonus_attack, :type => Float, :default => 0
  field :bonus_armor, :type => Float, :default => 0
  field :bonus_speed, :type => Float, :default => 0

  has_many :moves
  has_many :battle_effects

  validates_presence_of :battle, :team_character

  after_create :set_up_initial_stats
  before_save :restrict_below_zero

  def combined_speed
    self.speed + self.bonus_speed
  end

  def restrict_below_zero
    if self.health < 0
      self.health = 0
    end
    if self.speed < 0
      self.speed = 0
    end
    if self.attack < 0
      self.attack = 0
    end
    if self.armor < 0
      self.armor = 0
    end
  end

  def has_full_mana
    self.mana_available == self.mana_cost
  end

  def set_up_initial_stats
    self.health = self.team_character.character.health
    self.attack = self.team_character.character.base_attack
    self.speed = self.team_character.character.base_speed
    self.auto_type = self.team_character.character.auto_type
    if self.has_a_skill
      if self.team_character.character.skill.nature == :cast || self.team_character.character.skill.nature == :trigger
        self.mana_available = self.team_character.character.skill.starting_mana
        self.mana_cost = self.team_character.character.skill.mana_cost
      end
    end
    self.save!
  end

  def has_a_skill
    !self.team_character.character.skill.nil?
  end

end
