class GambitSerializer
  include FastJsonapi::ObjectSerializer
  set_id :_id
  attribute :is_final_gambit
end
