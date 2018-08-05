class Turn
  include BaseModel
  symbolize :status, :in => [:created, :in_progress, :resolved], :default => :created

  belongs_to :battle
  has_one :move_stack

  after_create :start_turn

  def start_turn
    trigger_start_of_turn_effects
    add_mana
    MoveStack.create!(:turn => self)
    trigger_end_of_turn_effects
    tick_poison
    tick_silence
    tick_stun
    remove_hidden
    remove_bonuses
    remove_overheal
    end_turn
  end

  def remove_overheal
    self.battle.reload.battle_team_characters.each do |char|
      if char.health > char.team_character.character.health
        char.health = char.team_character.character.health
        char.save!
      end
    end
  end

  def tick_poison
    self.battle.reload.battle_team_characters.where(:is_poisoned => true).each do |char|
      char.poison_turn_counter += 2
      char.health -= char.poison_turn_counter
      if char.health <= 0
        char.is_dead = true
      end
      char.save!
    end
  end

  def tick_silence
    self.battle.reload.battle_team_characters.where(:is_silenced => true).each do |char|
      char.silence_turn_counter += 1
      if char.silence_turn_counter == 2
        char.is_silenced = false
        char.silence_turn_counter = 0
      end
      char.save!
    end
  end

  def tick_stun
    self.battle.reload.battle_team_characters.where(:is_stunned => true).each do |char|
      char.is_stunned = false
      char.save!
    end
  end

  def remove_bonuses
    self.battle.reload.battle_team_characters.each do |char|
      char.bonus_speed = 0
      char.bonus_attack = 0
      char.bonus_armor = 0
      char.save!
    end
  end

  def remove_hidden
    self.battle.reload.battle_team_characters.each do |char|
      char.is_hidden = false
      char.save!
    end
  end

  def trigger_start_of_turn_effects
  end

  def trigger_end_of_turn_effects
  end

  def end_turn
    self.move_stack.status = :resolved
    self.move_stack.save!
    self.status = :resolved
    self.save!
    if !self.battle.reload.one_team_is_defeated
      self.battle.reload.create_turn
    else
      self.battle.reload.decide_winner
    end
  end

  def add_mana
    self.battle.reload.battle_team_characters.each do |char|
      if char.mana_cost != 0 && char.mana_available < char.mana_cost
        char.mana_available += 1
        char.save!
      end
    end
  end

end
