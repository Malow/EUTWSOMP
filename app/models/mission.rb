class Mission < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  has_many :participants
  has_many :users, :through => :participants
  
  validates_uniqueness_of :name
end
