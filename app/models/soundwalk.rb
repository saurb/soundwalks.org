class Soundwalk < ActiveRecord::Base
  attr_accessor :locations_file
  
  belongs_to :user
  has_many :sounds
  
  serialize :locations, Hash
  validates_presence_of :title, :description
  
  def before_save
    lines = locations_file.readlines
    
    self.locations = Hash.new
    
    lines.each_with_index do |line, index|
      components = line.split(',')
            
      self.locations[components[0].to_i] = [components[1].to_f, components[2].to_f]
      
      if index == 0
        self.lat = components[1].to_f
        self.lng = components[2].to_f
      end
    end
  end
end
