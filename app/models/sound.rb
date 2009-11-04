#-----------------------------------------------------------------------------------#
# A sound is owned by a soundwalk, which is owned by a user.                        #
#   A sound owns many features, and has one MDS node, which relates it to all other #
#   nodes (sounds and tags) in the network through links.                           #
#   A sound has many tags, which are applied by users.                              #
#-----------------------------------------------------------------------------------#

class Sound < ActiveRecord::Base
  include StringHelper
  include TimeHelper
  
  belongs_to :soundwalk
  belongs_to :user
  has_many :features, :dependent => :destroy
  has_one :mds_node, :as => :owner, :dependent => :destroy
  
  acts_as_taggable_on :tags
  acts_as_mappable :default_units => :miles, :default_formula => :flat    # Allows for location-based search.
  
  has_attachment :content_type => 'audio/x-wav',                          # Stores a .wav and .mp3 file. .wav is uploaded.
                 :storage => :file_system,                                # TODO: Support mp3 uploads.
                 :max_size => 10.megabytes,
                 :path_prefix => 'public/data/sounds'
  
  # Use the soundwalk's GPS path to locate the sound before creating it.
  before_validation_on_create do |record|
    record.localize
  end
  
  # When everything's done, analyze the sound's features, create the MP3 file, and apply a default title.
  after_attachment_saved do |record|
    record.analyze_sound
    record.create_preview
    record.title = record.filename if !record.title
    record.save
    
    record.create_mds_node
  end
  
  validates_as_attachment
  validates_presence_of :lat, :lng, :recorded_at
  validates_numericality_of :lat
  validates_numericality_of :lng
  
  #---------------------------------------------#
  # Returns the trajectory for a given feature. #
  #---------------------------------------------#
  
  def trajectory(feature_type)
    self.features.find(:all, :conditions => {:feature_type => feature_type}).first.trajectory
  end
  
  #-------------------------------------------------------------------------------------------------------------#
  # Assigns a location to the sound through interpolation on the GPS trace with the sound's file creation time. #
  #   TODO: There needs to be a better way to do this. The file creation time is only available on Macs.        #
  #-------------------------------------------------------------------------------------------------------------#
  
  def localize
    point = self.soundwalk.interpolate(self.recorded_at)
    
    self.lat = point.first
    self.lng = point.second
    self.lat = 0 if self.lat.nan?
    self.lng = 0 if self.lng.nan?
  end
  
  #---------------------------------------------------------------------------------#
  # Uses sirens-ruby to analyze the sound and saves the feature trajectory objects. #
  #---------------------------------------------------------------------------------#
  
  def analyze_sound
    begin
      self.study_coverage = 0
      
      sound_file = Sirens::Sound.new
      sound_file.frameLength = 0.04
      sound_file.hopLength = 0.02
      
      sound_file.open File.join('public', public_filename)
      
      self.sample_rate = sound_file.sampleRate
      self.samples = sound_file.samples
      self.frame_length = sound_file.frameLength
      self.hop_length = sound_file.hopLength
      self.frame_size = sound_file.samplesPerFrame
      self.hop_size = sound_file.samplesPerHop
      self.spectrum_size = sound_file.spectrumSize
      self.frames = sound_file.frames
      
      # Initialize features.
      loudness = Sirens::Loudness.new
      temporal_sparsity = Sirens::TemporalSparsity.new
      spectral_sparsity = Sirens::SpectralSparsity.new
      spectral_centroid = Sirens::SpectralCentroid.new
      harmonicity = Sirens::Harmonicity.new
      transient_index = Sirens::TransientIndex.new
      
      loudness.min = -60
      loudness.max = 0
      temporal_sparsity.min = 0
      temporal_sparsity.max = 0.5247
      spectral_sparsity.min = 0
      spectral_sparsity.max = 0.6509
      spectral_centroid.min = 0.4994
      spectral_centroid.max = 25.7848
      transient_index.min = 0.0197
      transient_index.max = 42.5258
      harmonicity.min = 0
      harmonicity.max = 0.5
      
      [loudness, temporal_sparsity, spectral_sparsity, spectral_centroid, harmonicity, transient_index].each do |feature|
        feature.maxHistorySize = sound_file.frames
      end
      
      [spectral_centroid, harmonicity, transient_index].each do |feature|
        feature.sampleRate = sound_file.sampleRate
        feature.spectrumSize = sound_file.spectrumSize
      end
      
      feature_set = Sirens::FeatureSet.new
      
      [loudness, temporal_sparsity].each do |feature|
        feature_set.addSampleFeature feature
      end
      
      [spectral_sparsity, spectral_centroid, transient_index, harmonicity].each do |feature|
        feature_set.addSpectralFeature feature
      end
      
      sound_file.featureSet = feature_set
      
      # Extract features.
      sound_file.extractFeatures
      sound_file.close
      
      self.save
      
      loudness_trajectory = get_or_create_feature(:loudness)
      loudness_trajectory.trajectory = loudness.history
      
      temporal_sparsity_trajectory = get_or_create_feature(:temporal_sparsity)
      temporal_sparsity_trajectory.trajectory = temporal_sparsity.history
      
      spectral_sparsity_trajectory = get_or_create_feature(:spectral_sparsity)
      spectral_sparsity_trajectory.trajectory = spectral_sparsity.history
      
      spectral_centroid_trajectory = get_or_create_feature(:spectral_centroid)
      spectral_centroid_trajectory.trajectory = spectral_centroid.history
      
      transient_index_trajectory = get_or_create_feature(:transient_index)
      transient_index_trajectory.trajectory = transient_index.history
      
      harmonicity_trajectory = get_or_create_feature(:harmonicity)
      harmonicity_trajectory.trajectory = harmonicity.history
      
      loudness_trajectory.save
      spectral_sparsity_trajectory.save
      spectral_centroid_trajectory.save
      temporal_sparsity_trajectory.save
      transient_index_trajectory.save
      harmonicity_trajectory.save
    rescue
      return false
    end
  end
  
  #--------------------------------------------------------------------------------#
  # If a feature doesn't already exist, create it. Useful to do this as opposed to #
  #   just created a new feature object for re-analyzing a sound.                  #
  #--------------------------------------------------------------------------------#
  
  def get_or_create_feature(type)
    results = self.features.find(:all, :conditions => {:feature_type => type})
    
    if results != nil && results.size > 0
      return results.first
    else
      feature = self.features.build
      feature.feature_type = type
      
      return feature
    end
  end
  
  #----------------------------------------------------------#
  # Creates a lower-quality MP3 file for streaming in Flash. #
  #----------------------------------------------------------#
  
  def create_preview
    system("/Users/brandon/bin/lame --quiet -b192 #{self.full_filename} #{self.full_filename}.mp3")
  end
  
  #----------------------------------------------#
  # Returns the formatted location of the sound. #
  #----------------------------------------------#
  
  def formatted_lat
    coordinates_text :latitude, self.lat
  end
  
  def formatted_lng
    coordinates_text :longitude, self.lng
  end
  
  #-------------------------------------------------------------#
  # Returns a the sound's RGB color, given its MDS coordinates. #
  #-------------------------------------------------------------#
  
  def color
    u = (mds_node.x - 0.5) * 0.436
    v = (mds_node.y - 0.5) * 0.615
    y = 0.5
    
    r = y + 1.13983 * v
    g = y - 0.39465 * u - 0.58060 * v
    b = y + 2.03211 * u
    
    return {:r => r, :g => g, :b => b}
  end
  
  #--------------------------------------------------------#
  # Methods that fetch information for XML/JSON rendering. #
  #--------------------------------------------------------#
  
  def color_red
    color[:r]
  end
  
  def color_green
    color[:g]
  end
  
  def color_blue
    color[:b]
  end
  
  def formatted_description
    return textilize(read_attribute(:description))
  end
  
  def formatted_recorded_at
    prettier_time self.recorded_at
  end
  
  def soundwalk_title
    return self.soundwalk.title
  end
  
  def user_login
    return self.soundwalk.user_login
  end
  
  def user_name
    return self.soundwalk.user_name
  end
  
  def user_id
    return self.soundwalk.user.id
  end
  
  #--------------------------------------------------------------------------#
  # Creates a sirens-ruby feature object from the stored feature trajectory. #
  #--------------------------------------------------------------------------#
  
  def unpack_feature feature_name
    if (feature_name == :loudness)
      feature = Sirens::Loudness.new
    elsif (feature_name == :temporal_sparsity)
      feature = Sirens::TemporalSparsity.new
    elsif (feature_name == :spectral_sparsity)
      feature = Sirens::SpectralSparsity.new
    elsif (feature_name == :spectral_centroid)
      feature = Sirens::SpectralCentroid.new
    elsif (feature_name == :transient_index)
      feature = Sirens::TransientIndex.new
    elsif (feature_name == :harmonicity)
      feature = Sirens::Harmonicity.new
    else
      return nil
    end
    
    trajectory = self.features.find(:all, :conditions => {:feature_type => feature_name}).first.trajectory
    
    feature.maxHistorySize = trajectory.size
    trajectory.each {|value| feature.addHistoryFrame value.to_f}
    
    return feature
  end
  
  #------------------------------------------------------------------------------------------#
  # Returns the segments of a sound. Not yet used.                                           #
  #   TODO: Use this to segment a sound on creation and allow the user to edit the segments. #
  #------------------------------------------------------------------------------------------#
  
  def segments
    loudness = unpack_feature(:loudness)
    spectral_sparsity = unpack_feature(:spectral_sparsity)
    spectral_centroid = unpack_feature(:spectral_centroid)
    
    feature_set = Sirens::FeatureSet.new     
    feature_set.addSampleFeature loudness
    feature_set.addSpectralFeature spectral_sparsity
    feature_set.addSpectralFeature spectral_centroid
    
    loudness.segmentationParameters.alpha = 0.15
    loudness.segmentationParameters.r = 0.0098
    loudness.segmentationParameters.cStayOff = 0.0015
    loudness.segmentationParameters.cTurnOn = 0.085
    loudness.segmentationParameters.cTurningOn = 0.085
    loudness.segmentationParameters.cTurnOff = 0.085
    loudness.segmentationParameters.cNewSegment = 0.085
    loudness.segmentationParameters.cStayOn = 0.05
    loudness.segmentationParameters.pLagPlus = 0.75
    loudness.segmentationParameters.pLagMinus = 0.75
    
    spectral_centroid.segmentationParameters.alpha = 0.05
    spectral_centroid.segmentationParameters.r = 0.00000196
    spectral_centroid.segmentationParameters.cStayOff = 0.0000933506
    spectral_centroid.segmentationParameters.cTurnOn = 0.85
    spectral_centroid.segmentationParameters.cTurningOn = 0.85
    spectral_centroid.segmentationParameters.cTurnOff = 0.85
    spectral_centroid.segmentationParameters.cNewSegment = 0.85
    spectral_centroid.segmentationParameters.cStayOn = 0.0025296018
    spectral_centroid.segmentationParameters.pLagPlus = 0.75
    spectral_centroid.segmentationParameters.pLagMinus = 0.075
    
    spectral_sparsity.segmentationParameters.alpha = 0.05
    spectral_sparsity.segmentationParameters.r = 0.0196
    spectral_sparsity.segmentationParameters.cStayOff = 0.001833506
    spectral_sparsity.segmentationParameters.cTurnOn = 0.85
    spectral_sparsity.segmentationParameters.cTurningOn = 0.85
    spectral_sparsity.segmentationParameters.cTurnOff = 0.85
    spectral_sparsity.segmentationParameters.cNewSegment = 0.85
    spectral_sparsity.segmentationParameters.cStayOn = 0.009296018
    spectral_sparsity.segmentationParameters.pLagPlus = 0.75
    spectral_sparsity.segmentationParameters.pLagMinus = 0.75
    
    #segmenter = Sirens::Segmenter.new
    #segmenter.featureSet = feature_set
    #segmenter.pNew = 0.00000000001
    #segmenter.pOff = 0.00000000001
    
    before = Time.now
    #segmenter.segment
    elapsed = Time.now - before
    puts "Segmentation took #{elapsed} seconds."
    
    #segmenter.segments.each do |start, stop|
    #  puts "%d-%d" % [start, stop]
    #end
  end

  #-----------------------------------------------------------------------------------------------#
  # Returns a sirens-ruby comparator object of a sound based off its stored feature trajectories. #
  #-----------------------------------------------------------------------------------------------#
  
  def get_comparator
    if self.features.count < 6
      analyze_sound
    end
    
    l = unpack_feature(:loudness)
    ts = unpack_feature(:temporal_sparsity)
    ss = unpack_feature(:spectral_sparsity)
    sc = unpack_feature(:spectral_centroid)
    ti = unpack_feature(:transient_index)
    h = unpack_feature(:harmonicity)
    
    set = Sirens::FeatureSet.new
    
    [l, ts].each do |f|
      set.addSampleFeature f
    end
    
    [ss, sc, ti, h].each do |f|
      set.addSpectralFeature f
    end
    
    comparator = Sirens::SoundComparator.new
    comparator.featureSet = set
    
    return comparator
  end
  
  #------------------------------------------------------------------------------------------#
  # Compares one sound to another by fetching their comparators on demand. Optionally allows #
  #   you to pass in the comparator for the first sound if it's already been created.        #
  #------------------------------------------------------------------------------------------#
  
  def compare(other, first_comparator = nil)
    first_comparator = get_comparator if (first_comparator == nil)
    second_comparator = other.get_comparator
    
    return first_comparator.compare(second_comparator)
  end
end
