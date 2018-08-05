class MoveStack
  include BaseModel
  symbolize :status, :in => [:created, :resolved], :default => :created

  belongs_to :turn
  has_many :moves

  validates_presence_of :turn

  after_create :create_stack

  def make_skill_move(char)
    trigger_char = self.turn.battle.next_skill_trigger(char.battle_team)
    if trigger_char.present?
      make_skill_trigger_move(trigger_char, char)
    else
      Move.create!(:move_stack => self, :battle_team_character => char, :skill => char.team_character.character.skill, :status => char.team_character.character.skill.type)
    end
  end

  def make_auto_attack_move(char)
    trigger_char = self.turn.battle.next_auto_trigger(char.battle_team)
    if trigger_char.present?
      make_auto_trigger_move(trigger_char, char)
    else
      Move.create!(:move_stack => self, :battle_team_character => char, :status => :auto_attack)
    end
  end

  def make_auto_trigger_move(trigger_char, initial_char)
    trigger_char.mana_available = 0
    trigger_char.save!
    Move.create!(:move_stack => self, :battle_team_character => trigger_char, :skill => trigger_char.team_character.character.skill, :status => trigger_char.team_character.character.skill.type)
    if !initial_char.reload.is_dead && !trigger_char.team_character.character.skill.block
      Move.create!(:move_stack => self, :battle_team_character => initial_char, :status => :auto_attack)
    end
  end

  def make_skill_trigger_move(trigger_char, initial_char)
    trigger_char.mana_available = 0
    trigger_char.save!
    Move.create!(:move_stack => self, :battle_team_character => trigger_char, :skill => trigger_char.team_character.character.skill, :status => trigger_char.team_character.character.skill.type)
    if !initial_char.reload.is_dead && !trigger_char.team_character.character.skill.block
      Move.create!(:move_stack => self, :battle_team_character => initial_char, :skill => initial_char.team_character.character.skill, :status => initial_char.team_character.character.skill.type)
    end
  end

  def create_stack
    all_chars = self.turn.battle.battle_team_characters
    all_alive_chars = all_chars.order('combined_speed desc')
    all_alive_chars.where(:is_dead => false).each do |char|
      if !char.reload.is_dead
        if char.has_a_skill
          if char.team_character.character.skill.nature == :cast
            if char.has_full_mana
              char.mana_available = 0
              char.save!
              make_skill_move(char)
            else
              make_auto_attack_move(char)
            end
          else
            make_skill_move(char)
          end
        else
          make_auto_attack_move(char)
        end
      end
    end
  end

end
