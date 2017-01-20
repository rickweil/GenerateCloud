class CreatePatients < ActiveRecord::Migration[5.0]
  def change
    create_table :patients do |t|
      t.string :pid
      t.date :date_of_birth
      t.string :sex
      t.string :first_name
      t.string :last_name
      t.references :business, foreign_key: true
      t.string :email_address

      t.timestamps
    end
  end
end
