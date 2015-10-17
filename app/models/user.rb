class User < ActiveRecord::Base
  has_many :created_missions, :class_name => "Mission", :foreign_key => 'creator_id'
  has_many :participants
  has_many :missions, :through => :participants
  
  validates_uniqueness_of :email
  validates_uniqueness_of :username

  def self.authenticate_by_username(username, password)
    user = User.where(:username => username).first
    if user && user.password == password
      user
    else
      nil
    end
  end

end