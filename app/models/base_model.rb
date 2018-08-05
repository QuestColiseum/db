module BaseModel
  def self.included(base)
    base.send :include, Mongoid::Document
    base.send :include, Mongoid::Timestamps
    base.send :include, Mongoid::Paranoia
    base.send :include, Mongoid::Symbolize
    #base.send :after_save, :search_reindex
  end
end
