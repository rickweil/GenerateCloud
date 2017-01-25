class Patient < ApplicationRecord
  belongs_to :business
  belongs_to :status
end
