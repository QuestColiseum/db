class Move
  include BaseModel
  symbolize :status, :in => [:auto_attack, :auto_with_skill, :no_auto]

  belongs_to :move_stack
  belongs_to :battle_team_character
  has_one :effect_stack
  belongs_to :skill

  after_create :trigger_effect_stack

  validates_presence_of :battle_team_character, :status

  def trigger_effect_stack
    EffectStack.create!(:move => self)
    self.battle_team_character.has_moved_for_turn = true
    self.battle_team_character.save!
  end
end
