class Soundwalk < ActiveRecord::Base
  attr_accessor :locations_file
  
  belongs_to :user
  has_many :sounds
  serialize :locations, Hash
  validates_presence_of :title, :description
  
  def before_save
    lines = locations_file.readlines
    
    self.locations = Hash.new
    
    lines.each do |line|
      components = line.split(',')
            
      self.locations[components[0].to_i] = Array[components[1].to_f, components[2].to_f]
    end
  end
end
