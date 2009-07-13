class Soundwalk < ActiveRecord::Base
  attr_accessor :locations_file
  
  belongs_to :user
  has_many :sounds
  serialize :locations, Hash
  validates_presence_of :title, :description
  
  def before_save
    lines = locations_file.readlines
    
    self.locations = Hash.new
    
    total_lat = 0
    total_lng = 0
    
    lines.each do |line|
      components = line.split(',')
            
      self.locations[components[0].to_i] = [components[1].to_f, components[2].to_f]
      total_lat += components[1].to_f
      total_lng += components[2].to_f
    end
    
    self.lat = total_lat / lines.size
    self.lng = total_lng / lines.size
  end
end
