json.extract! consumable, :id, :udi, :expiration_date, :created_at, :updated_at
json.url consumable_url(consumable, format: :json)