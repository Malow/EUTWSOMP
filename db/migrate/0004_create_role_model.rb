class CreateRoleModel < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.column :name, :string
      t.column :description, :string
    end
  end
end
