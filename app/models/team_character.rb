class TeamCharacter
  include BaseModel

  belongs_to :team
  belongs_to :character

  validates_presence_of :team, :character
end
