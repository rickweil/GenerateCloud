class CreateBusinesses < ActiveRecord::Migration[5.0]
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :website
      t.string :address
      t.string :email
      t.string :phone
      t.string :logo_url
      t.references :status, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
