class AddRoleToStudent < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :role, :string
  end
end
