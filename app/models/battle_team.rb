class BattleTeam
  include BaseModel

  belongs_to :team
  belongs_to :battle

  has_many :battle_team_characters

  validates_presence_of :team, :battle
end
