class Tag < ActiveRecord::Base
  has_many :taggings
  validates_presence_of :name
  validates_uniqueness_of :name
  has_one :mds_node, :as => :owner, :dependent => :destroy
  
  after_save do |record|
    record.create_mds_node
  end
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
end
