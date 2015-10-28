class Role < ActiveRecord::Base
  has_many :role_preferences
  has_many :users, :through => :role_preferences
  
  validates_uniqueness_of :name
end