class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.references :user, foreign_key: true
      t.references :patient, foreign_key: true
      t.references :business, foreign_key: true
      t.references :device, foreign_key: true
      t.references :consumable, foreign_key: true
      t.float :value
      t.datetime :result_datetime
      t.string :notes

      t.timestamps
    end
  end
end
