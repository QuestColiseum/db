class EffectStack
  include BaseModel
  symbolize :status, :in => [:created, :resolved], :default => :created

  belongs_to :move
  has_many :battle_effects

  after_create :run_effects

  def skill
    self.move.battle_team_character.team_character.character.skill
  end

  def decode_auto_with_skill(target)
    BattleEffect.create!(
      :effect_stack => self,
      :battle_team_character => target,
      :damage_points => calculated_damage(target),
      :apply_silence => skill.apply_silence,
      :apply_poison => skill.apply_poison,
      :apply_stun => skill.apply_stun
    )
  end

  def decode_no_auto
    if skill.reload.target == :summon
      BattleEffect.create!(
        :effect_stack => self,
        :battle_team_character => self.move.battle_team_character,
        :team_character => skill.team_character,
        :battle_team => self.move.battle_team_character.battle_team
      )
    else
      targets = decode_targets
      if targets.length > 0 && targets.first.present?
        targets.each do |target|
          BattleEffect.create!(
            :effect_stack => self,
            :battle_team_character => target,
            :damage_points => skill.flat_damage,
            :apply_silence => skill.apply_silence,
            :apply_poison => skill.apply_poison,
            :apply_stun => skill.apply_stun,
            :heal_status => skill.heal_status,
            :is_heal => skill.is_heal,
            :chance_to_hit => skill.chance_to_hit,
            :chance_to_hit_effect => skill.chance_to_hit_effect,
            :buff_points => skill.buff_points,
            :is_bonus => skill.is_bonus,
            :is_buff_attack => skill.is_buff_attack,
            :is_debuff_attack => skill.is_debuff_attack,
            :is_buff_armor => skill.is_buff_armor,
            :is_debuff_armor => skill.is_debuff_armor,
            :is_buff_speed => skill.is_buff_speed,
            :is_debuff_speed => skill.is_debuff_speed,
          )
        end
      end
    end
    if skill.add_one_auto_to_stack
      commence_auto_attack
    end
    if skill.add_two_autos_to_stack
      2.times {commence_auto_attack;}
    end
    if skill.add_three_autos_to_stack
      3.times {commence_auto_attack;}
    end
    if skill.add_four_autos_to_stack
      4.times {commence_auto_attack;}
    end
  end

  def commence_auto_attack
    target = choose_standard_enemy_target
    if target.present?
      BattleEffect.create!(:effect_stack => self, :battle_team_character => target, :damage_points => calculated_damage(target))
    end
  end

  def decode_targets
    if skill.reload.target == :single
      [choose_standard_enemy_target]
    elsif skill.reload.target == :random_single
      [choose_random_enemy_target]
    elsif skill.reload.target == :double
      enemy_team.battle_team_characters.where(:is_dead => false).sample(2)
    elsif skill.reload.target == :triple
      enemy_team.battle_team_characters.where(:is_dead => false).sample(3)
    elsif skill.reload.target == :area_of_effect
      enemy_team.battle_team_characters.where(:is_dead => false)
    elsif skill.reload.target == :friendly_single
      own_team.battle_team_characters.where(:is_dead => false).sample
    elsif skill.reload.target == :friendly_double
      own_team.battle_team_characters.where(:is_dead => false).sample(2)
    elsif skill.reload.target == :friendly_triple
      own_team.battle_team_characters.where(:is_dead => false).sample(3)
    elsif skill.reload.target == :friendly_area_of_effect
      own_team.battle_team_characters.where(:is_dead => false)
    end
  end

  def own_team
    self.move.battle_team_character.battle_team
  end

  def enemy_team
    own_team.battle.battle_teams.where(:id.ne => own_team._id).first
  end

  def choose_random_enemy_target
    enemy_team.battle_team_characters.where(:is_dead => false).sample
  end

  def choose_melee_enemy_target
    enemy_team.battle_team_characters.where(:is_dead => false, :auto_type => :melee).sample
  end

  def choose_ranged_enemy_target
    enemy_team.battle_team_characters.where(:is_dead => false, :auto_type => :ranged).sample
  end

  def choose_standard_enemy_target
    target = choose_melee_enemy_target
    if !target.present?
      target = choose_ranged_enemy_target
    end
    target
  end

  def calculated_damage(target)
    armor = target.armor + target.bonus_armor
    attack = self.move.battle_team_character.attack + self.move.battle_team_character.bonus_attack
    attack > armor ? attack - armor : 1
  end

  def run_effects
    if self.move.status == :auto_attack
      commence_auto_attack
    elsif self.move.status == :auto_with_skill
      target = choose_standard_enemy_target
      if target.present?
        decode_auto_with_skill(target)
      end
    elsif self.move.status == :no_auto
      decode_no_auto
    end
  end

  validates_presence_of :move
end
