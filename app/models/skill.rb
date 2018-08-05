class Skill
  include BaseModel
  belongs_to :character
  belongs_to :team_character
  has_many :moves
  symbolize :nature, :in => [:constant, :start_of_game, :cast, :trigger]
  symbolize :target, :in => [
    :single,
    :double,
    :triple,
    :area_of_effect,
    :friendly_single,
    :friendly_double,
    :friendly_triple,
    :friendly_area_of_effect,
    :summon,
  ]
  symbolize :type, :in => [:auto_with_skill, :no_auto], :default => :no_auto

  field :mana_cost, :type => Float, :default => 0
  field :starting_mana, :type => Float, :default => 0

  field :friendly_auto_trigger, :type => Boolean, :default => false
  field :friendly_skill_trigger, :type => Boolean, :default => false
  field :enemy_auto_trigger, :type => Boolean, :default => false
  field :enemy_skill_trigger, :type => Boolean, :default => false
  field :counter_attack_trigger, :type => Boolean, :default => false
  field :counter_spell_trigger, :type => Boolean, :default => false

  field :flat_damage, :type => Float, :default => 0
  field :self_inflict_damage, :type => Float, :default => 0
  field :buff_points, :type => Float, :default => 0
  field :is_bonus, :type => Boolean, :default => false

  field :is_buff_attack, :type => Boolean, :default => false
  field :is_debuff_attack, :type => Boolean, :default => false
  field :is_buff_armor, :type => Boolean, :default => false
  field :is_debuff_armor, :type => Boolean, :default => false
  field :is_buff_speed, :type => Boolean, :default => false
  field :is_debuff_speed, :type => Boolean, :default => false

  field :is_heal, :type => Float, :type => Boolean, :default => false
  field :chance_to_hit, :type => Boolean, :default => false
  field :chance_to_hit_effect, :type => Boolean, :default => false
  field :apply_silence, :type => Boolean, :default => false
  field :apply_poison, :type => Boolean, :default => false
  field :apply_stun, :type => Boolean, :default => false
  field :heal_status, :type => Boolean, :default => false

  field :add_one_auto_to_stack, :type => Boolean, :default => false
  field :add_two_autos_to_stack, :type => Boolean, :default => false
  field :add_three_autos_to_stack, :type => Boolean, :default => false
  field :add_four_autos_to_stack, :type => Boolean, :default => false

  field :intercept_attack, :type => Boolean, :default => false
  field :block, :type => Boolean, :default => false
  field :copy_skill, :type => Boolean, :default => false

end
