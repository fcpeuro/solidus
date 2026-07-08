# frozen_string_literal: true

json.roles(@roles) do |role|
  json.partial!("spree/api/roles/role", role:)
end
json.partial! "spree/api/shared/pagination", pagination: @roles
