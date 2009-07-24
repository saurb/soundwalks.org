require 'gpx'

class Soundwalk < ActiveRecord::Base
  belongs_to :user
  has_many :sounds
  
  serialize :locations, Array
  validates_presence_of :title, :description
    
  has_attachment :content_type => ['application/gpx+xml', 'text/xml'],
                 :storage => :file_system,
                 :max_size => 10.megabytes,
                 :path_prefix => 'public/data/gps'
  
  after_attachment_saved do |record|
    record.extract_locations
  end
             
  validates_as_attachment
  
  named_scope :from_users, lambda { |user_ids, options| 
    id_string = user_ids.map{|id| "#{id}, "}.to_s.chomp(', ')
    options[:conditions] = "user_id in (#{id_string})"
    return options
  }
  
  def times
    return self.locations.collect {|point| point.first}
  end
  
  def vertices
    return self.locations.collect {|point| [point.second, point.third]}
  end
  
  def latitudes
    return self.locations.collect {|point| point.second}
  end
  
  def longitudes
    return self.locations.collect {|point| point.third}
  end
  
  def interpolate time
    # Uses linear interpolation to find the approximate location of a point in time. 
    # Extrapolates if beyond bounds.
    
    if times.index(time)
      return vertices[times.index(time)]
    elsif time < self.locations.first.first
      time_diff = times.second - times.first
      lat_diff = latitudes.second - latitudes.first
      lng_diff = longitudes.second - longitudes.first
      
      lat_slope = lat_diff / time_diff
      lng_slope = lng_diff / time_diff
      
      time_offset = time - times.first
      return [latitudes.first + lat_slope * time_offset, longitudes.first + lng_slope * time_offset]
    elsif time > self.locations.last.first
      time_diff = times.last - times[times.size - 2]
      lat_diff = latitudes.last - latitutdes[latitudes.size - 2]
      lng_diff = longitudes.last - longitudes[longitudes.size - 2]
      
      lat_slope = lat_diff / time_diff
      lng_slope = lng_diff / time_diff
      
      time_offset = time - times.last
      
      return [latitudes.last + lat_slope * time_offset, longitudes.first + lng_slope * time_offset]
    else
      index = 0
      
      times.each_with_index do |value, i|
        if value > time
          index = i
          break
        end
      end
      
      alpha = (times[index] - time) / (times[index] - times[index - 1])
      latitude = latitudes[index] * (1 - alpha) + latitudes[index - 1] * alpha
      longitude = longitudes[index] * (1 - alpha) + longitudes[index - 1] * alpha
      
      return [latitude, longitude]
    end 
  end
  
  def extract_locations
    # Extract the track data.
    self.locations = Array.new
    
    gpx_file = GPX::GPXFile.new(:gpx_file => File.join('public', public_filename))
    gpx_file.tracks.each do |track|
      track.points.each do |point|
        if point.time && point.lat && point.lon
          self.locations.push [point.time, point.lat, point.lon]
        end
      end
    end
    
    if self.locations.size
      self.locations = self.locations.sort
      
      self.lat = self.locations[0][1]
      self.lng = self.locations[0][2]
    end 
  end
end
