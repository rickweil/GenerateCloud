class AddSuperAdminRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :super_admin_role, :boolean
  end
end
