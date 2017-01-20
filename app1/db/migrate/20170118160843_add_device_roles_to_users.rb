class AddDeviceRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :device_role, :boolean
  end
end
