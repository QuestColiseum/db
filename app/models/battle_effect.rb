class BattleEffect
  include BaseModel

  belongs_to :effect_stack
  belongs_to :battle_team_character
  belongs_to :team_character
  belongs_to :battle_team
  has_many :battle_team_characters
  has_one :skill

  field :is_response, :type => Boolean, :default => false
  field :damage_points, :type => Float
  field :is_heal, :type => Boolean, :default => false

  field :buff_points, :type => Float, :default => 0
  field :is_bonus, :type => Boolean, :default => false

  field :is_buff_attack, :type => Boolean, :default => false
  field :is_debuff_attack, :type => Boolean, :default => false
  field :is_buff_armor, :type => Boolean, :default => false
  field :is_debuff_armor, :type => Boolean, :default => false
  field :is_buff_speed, :type => Boolean, :default => false
  field :is_debuff_speed, :type => Boolean, :default => false
  field :chance_to_hit, :type => Boolean, :default => false
  field :chance_to_hit_effect, :type => Boolean, :default => false

  field :heal_status, :type => Boolean, :default => false
  field :apply_silence, :type => Boolean, :default => false
  field :apply_poison, :type => Boolean, :default => false
  field :apply_stun, :type => Boolean, :default => false

  validates_presence_of :effect_stack, :battle_team_character

  after_create :resolve

  def resolve_health_change
    if self.damage_points
      if self.is_heal
        self.battle_team_character.health += self.damage_points
      else
        self.battle_team_character.health -= self.damage_points
      end
    end
  end

  def resolve_status_change
    if self.apply_silence
      self.battle_team_character.is_silenced = true
    elsif self.apply_poison
      self.battle_team_character.is_poisoned = true
    elsif self.apply_stun
      self.battle_team_character.is_stunned = true
    elsif self.heal_status
      self.battle_team_character.is_silenced = false
      self.battle_team_character.is_poisoned = false
      self.battle_team_character.is_stunned = false
    end
  end

  def resolve_stat_change
    if self.is_buff_attack
      if self.is_bonus
        self.battle_team_character.bonus_attack += self.buff_points
      else
        self.battle_team_character.attack += self.buff_points
      end
    elsif self.is_debuff_attack
      if self.is_bonus
        self.battle_team_character.bonus_attack -= self.buff_points
      else
        self.battle_team_character.attack -= self.buff_points
      end
    elsif self.is_buff_armor
      if self.is_bonus
        self.battle_team_character.bonus_armor += self.buff_points
      else
        self.battle_team_character.armor += self.buff_points
      end
    elsif self.is_debuff_armor
      if self.is_bonus
        self.battle_team_character.bonus_armor -= self.buff_points
      else
        self.battle_team_character.armor -= self.buff_points
      end
    elsif self.is_buff_speed
      if self.is_bonus
        self.battle_team_character.bonus_speed += self.buff_points
      else
        self.battle_team_character.speed += self.buff_points
      end
    elsif self.is_debuff_speed
      if self.is_bonus
        self.battle_team_character.bonus_speed -= self.buff_points
      else
        self.battle_team_character.speed -= self.buff_points
      end
    end
  end

  def resolve_summon
    if self.team_character.present? && self.battle_team.present?
      BattleTeamCharacter.create!(:team_character => self.team_character, :battle_team => self.battle_team, :battle => self.battle_team.battle)
    end
  end

  def check_death
    if self.battle_team_character.health <= 0
      self.battle_team_character.is_dead = true
    end
  end

  def resolve_effect
    resolve_health_change
    if self.chance_to_hit_effect
      [1,0].sample == 1 ? resolve_status_change : nil
    else
      resolve_status_change
    end
    resolve_stat_change
    resolve_summon
  end

  def resolve
    if self.chance_to_hit
      [1,0].sample == 1 ? resolve_effect : nil
    else
      resolve_effect
    end
    check_death
    self.battle_team_character.save!
  end

end
