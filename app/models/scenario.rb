class Scenario
  include BaseModel

  symbolize :type, :in => [:invest, :spend, :created, :first_hero_offer], :default => :created
  symbolize :status, :in => [:completed, :pending], :default => :pending
  field :total_available_gambits, :type => Float, :default => 1

  has_many :gambits
  belongs_to :quest_level

  def check_gambits
    if self.status != :completed
      if self.gambits.length == self.total_available_gambits
        self.status = :completed
        self.save!
      end
      self.quest_level.trigger_check_status
    end
  end

  def has_no_gambits_remaining
    self.gambits.length > self.total_available_gambits
  end
end
