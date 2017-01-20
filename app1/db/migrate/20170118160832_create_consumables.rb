class CreateConsumables < ActiveRecord::Migration[5.0]
  def change
    create_table :consumables do |t|
      t.string :udi
      t.date :expiration_date

      t.timestamps
    end
  end
end
