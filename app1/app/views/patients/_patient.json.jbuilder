json.extract! patient, :id, :pid, :date_of_birth, :sex, :first_name, :last_name, :business_id, :email_address, :created_at, :updated_at
json.url patient_url(patient, format: :json)