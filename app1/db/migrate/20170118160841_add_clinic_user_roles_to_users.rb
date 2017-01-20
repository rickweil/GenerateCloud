class AddClinicUserRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :clinic_user_role, :boolean
  end
end
