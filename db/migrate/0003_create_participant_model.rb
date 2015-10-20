class CreateParticipantModel < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.column "mission_id", :integer
      t.column "user_id", :integer
      t.column "role", :string
      t.column "slot_id", :integer
      t.column "joined_at", :datetime
      t.column "is_mission_admin", :boolean
    end
  end
end