class AddStatusToPatients < ActiveRecord::Migration[5.0]
  def change
    add_reference :patients, :status , foreign_key: true
  end
end
