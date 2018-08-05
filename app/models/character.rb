class Character
  include BaseModel
  field :health, :type => Float
  field :base_attack, :type => Float
  field :base_speed, :type => Float
  field :character_id, :type => Float
  field :name, :type => String
  symbolize :auto_type, :in => [:ranged, :melee]

  has_one :skill
  has_many :gambits
  has_many :team_characters

  validates_presence_of :health, :base_attack, :base_speed, :character_id, :name, :auto_type

end
