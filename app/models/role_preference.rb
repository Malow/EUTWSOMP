class RolePreference < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
  
  validates_uniqueness_of :user, :scope => [:role]
end