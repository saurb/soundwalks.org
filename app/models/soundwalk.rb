require 'gpx'

#----------------------------------------------------------------------------------------------------#
# A soundwalk is owned by a user and owns many sounds.                                               #
#   Soundwalks can be public, friends-only, or private, which affects whether or not different users #
#   can see the soundwalk and all the sounds within it.                                              #
#   A soundwalk also has a serialized list of locations/times that form a GPS trace.                 #
#   Soundwalks are associated with a .gpx file for the GPS trace.                                    #
#----------------------------------------------------------------------------------------------------#

class Soundwalk < ActiveRecord::Base
  include StringHelper
  
  belongs_to :user
  has_many :sounds, :dependent => :destroy, :order => 'recorded_at ASC'
  
  serialize :locations, Array
  
  has_attachment :content_type => ['application/gpx+xml', 'text/xml'],
                 :storage => :file_system,
                 :max_size => 10.megabytes,
                 :path_prefix => 'public/data/gps'
             
  validates_as_attachment
  validates_presence_of :title, :description, :privacy
  
  # After everything's done, open the GPX file and update the locations member.
  after_attachment_saved do |record|
    record.extract_locations
    record.save
  end
  
  # Allows soundwalks to be fetched from a list of friends to account for privacy restrictions.
  named_scope :from_friends, lambda { |friend_ids, public_ids, my_id, options| 
    public_string = public_ids.join(', ')
    
    friend_sql = ""
    friend_sql = " or (user_id in (#{friend_ids.join(', ')}) and not privacy='private')" if friend_ids.size > 0
    public_sql = ""
    public_sql = " or (user_id in (#{public_ids.join(', ')}) and privacy='public')" if public_ids.size > 0
    
    options[:conditions] = "(user_id = #{my_id})" + friend_sql + public_sql
      
    return options
  }
  
  #-------------------------------------------------#
  # Methods for returning lists from the GPS trace. #
  #-------------------------------------------------#
  
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
  
  #--------------------------------------------------------#
  # Methods that fetch information for XML/JSON rendering. #
  #--------------------------------------------------------#
  
  def user_login
    return self.user.login
  end
  
  def user_name
    return self.user.name
  end
  
  def formatted_description
    return textilize(read_attribute(:description))
  end
  
  def formatted_lat
    coordinates_text :latitude, self.lat
  end
  
  def formatted_lng
    coordinates_text :longitude, self.lng
  end
  
  #--------------------------------------------------------------------------------------------------#
  # Computes a latitude/longitude pair for a given time using linear interpolation on the GPS trace. #
  #   If the time is beyond the start/stop time of the soundwalk, the location will be extrapolated. #
  #--------------------------------------------------------------------------------------------------#
  
  def interpolate time
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
      lat_diff = latitudes.last - latitudes[latitudes.size - 2]
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
  
  #-------------------------------------------------------------------------#
  # Loads the uploaded GPX file stores the locations/times in the database. #
  #-------------------------------------------------------------------------#    
  
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
