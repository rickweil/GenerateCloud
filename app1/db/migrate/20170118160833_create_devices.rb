class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.references :business, foreign_key: true
      t.integer :serial_number
      t.string :software_version
      t.string :mac_address
      t.float :latitude
      t.float :longitude
      t.string :license_key
      t.date :license_expiration_date
      t.integer :license_remaining_uses

      t.timestamps
    end
  end
end
