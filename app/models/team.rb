class Team
  include BaseModel

  belongs_to :teamable, :autosave => false, :polymorphic => true
  has_many :team_characters

  validates_presence_of :teamable
end
