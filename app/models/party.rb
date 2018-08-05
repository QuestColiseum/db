class Party
  include BaseModel
  include Teamable

  symbolize :gambit_per_scenario, :in => [:one, :two, :three, :four], :default => :one

  belongs_to :quest
  after_create :init_team

  def init_team
    Team.create(:teamable => self)
  end

  validates_presence_of :quest
end
