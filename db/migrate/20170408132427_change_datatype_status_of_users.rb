class ChangeDatatypeStatusOfUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :status, :integer
  end
end
