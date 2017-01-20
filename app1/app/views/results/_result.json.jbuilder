json.extract! result, :id, :user_id, :patient_id, :business_id, :device_id, :consumable_id, :value, :result_datetime, :notes, :created_at, :updated_at
json.url result_url(result, format: :json)