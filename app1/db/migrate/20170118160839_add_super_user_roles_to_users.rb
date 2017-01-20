class AddSuperUserRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :super_user_role, :boolean
  end
end
