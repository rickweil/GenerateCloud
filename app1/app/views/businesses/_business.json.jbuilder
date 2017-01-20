json.extract! business, :id, :name, :website, :address, :email, :phone, :logo_url, :status_id, :notes, :created_at, :updated_at
json.url business_url(business, format: :json)