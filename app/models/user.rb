class User < ActiveRecord::Base
  
  validates_uniqueness_of :email
  validates_uniqueness_of :username

  def initialize(attributes = {})
    super     # must allow the active record to initialize!
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def update(attributes = {})
    super     # must allow the active record to initialize!
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.authenticate_by_username(username, password)
    user = User.where(:username => username).first
    if user && user.password == password
      user
    else
      nil
    end
  end

end