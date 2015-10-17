class Participant < ActiveRecord::Base
  belongs_to :mission
  belongs_to :user
  
  validates_uniqueness_of :user, :scope => [:mission]
end