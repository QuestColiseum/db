module Teamable
  def self.included(base)
    base.send :has_one, :team, :as => :teamable
  end
end
