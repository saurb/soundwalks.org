require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  
  has_many :soundwalks
  has_many :sounds, :through => :soundwalks
  
  validates_presence_of     :name
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
    
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  def self.valid_login?(login)
    return false if login.blank?
    return find_in_state(:first, :active, :conditions => {:login => login.downcase})
  end
  
  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def friends_soundwalks(options = {})
    options[:order] = 'created_at DESC, title'
    Soundwalk.from_users(self.friendships.map{|friendship| friendship.friend_id}.compact.concat([self.id]), options)
  end
  
  def inverse_friends_soundwalks(options = {})
    options[:order] = 'created_at DESC, title'
    Soundwalk.from_users(self.inverse_friendships.map{|friendship| friendship.friend_id}.compact.concat([self.id]), options)
  end
  
  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
end
