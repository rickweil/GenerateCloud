class Result < ApplicationRecord
  belongs_to :user
  belongs_to :patient
  belongs_to :business
  belongs_to :device
  belongs_to :consumable
end
