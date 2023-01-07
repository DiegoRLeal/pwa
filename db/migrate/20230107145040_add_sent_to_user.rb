class AddSentToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :sent, :boolean
  end
end
