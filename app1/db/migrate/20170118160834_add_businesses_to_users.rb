class AddBusinessesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :business, foreign_key: true
  end
end
