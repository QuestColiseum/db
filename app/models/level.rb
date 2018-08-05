class Level
  include BaseModel
  include Teamable
  field :number, :type => Float

  belongs_to :stage
  has_many :quest_levels

  validates_presence_of :stage, :number
end
