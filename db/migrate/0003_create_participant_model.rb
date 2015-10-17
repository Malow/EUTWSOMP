class CreateParticipantModel < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.column "mission_id", :integer
      t.column "user_id", :integer
      t.column "role", :string
      t.column "slot_id", :integer
      t.column "joined_at", :datetime
    end
  end
end