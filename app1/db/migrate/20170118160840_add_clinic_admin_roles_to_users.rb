class AddClinicAdminRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :clinic_admin_role, :boolean
  end
end
