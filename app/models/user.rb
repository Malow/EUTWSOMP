class User < ActiveRecord::Base
  has_and_belongs_to_many :joined_missions, :class_name => "Mission"
  has_many :created_missions, :class_name => "Mission"
  
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