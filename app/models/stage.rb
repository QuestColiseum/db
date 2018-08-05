class Stage
  include BaseModel
  field :name, :type => String
  field :number, :type => Float

  has_many :quests
  has_many :levels

  validates_presence_of :name, :number
end
