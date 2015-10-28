class CreateRolePreferenceModel < ActiveRecord::Migration
  def change
    create_table :role_preferences do |t|
      t.column "role_id", :integer
      t.column "user_id", :integer
      t.column "preference", :integer
    end
  end
end