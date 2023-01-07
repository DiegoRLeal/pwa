class AddCodigoToStudent < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :codigo, :string
  end
end
