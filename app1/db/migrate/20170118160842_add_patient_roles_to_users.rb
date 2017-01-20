class AddPatientRolesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :patient_role, :boolean
  end
end
