class BaseSerializer
  include FastJsonapi::ObjectSerializer
  set_id :_id
end
