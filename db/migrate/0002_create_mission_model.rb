class CreateMissions < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.column :name, :string
      t.column :date, :datetime
      t.belongs_to :user, index:true
    end
    
    create_table :missions_users, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :mission, index: true
    end
  end
end