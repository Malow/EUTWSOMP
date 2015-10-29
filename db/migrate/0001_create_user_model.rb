class CreateUserModel < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.column :username, :string
      t.column :email, :string
      t.column :password, :string
      t.column :last_signed_in_on, :datetime
      t.column :signed_up_on, :datetime
      t.column :is_admin, :boolean
      t.column :password_reset_token, :string
      t.column :password_expires_after, :datetime
    end
  end
end
