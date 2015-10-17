class CreateMissionModel < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.column :name, :string
      t.column :date, :datetime
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.belongs_to :creator, index:true
    end
  end
end