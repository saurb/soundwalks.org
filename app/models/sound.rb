require 'sirens'

class Sound < ActiveRecord::Base
  include StringHelper
  include TimeHelper
  
  belongs_to :soundwalk
  belongs_to :user
  has_many :features
  
  acts_as_taggable_on :tags
  acts_as_mappable
  has_attachment :content_type => 'audio/x-wav',
                 :storage => :file_system,
                 :max_size => 10.megabytes,
                 :path_prefix => 'public/data/sounds'
              
  before_validation_on_create do |record|
    record.localize
  end
  
  after_attachment_saved do |record|
    record.analyze_sound
    record.save
  end
  
  validates_as_attachment
  validates_presence_of :lat, :lng, :recorded_at
  validates_numericality_of :lat
  validates_numericality_of :lng
  
  def trajectory(feature_type)
    self.features.find(:all, :conditions => {:feature_type => feature_type}).first.trajectory
  end
  
  def localize
    point = self.soundwalk.interpolate(self.recorded_at)
      
    self.lat = point.first
    self.lng = point.second
  end
  
  def analyze_sound
    #begin
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
      harmonicity.absThreshold = 1
      harmonicity.threshold = 0.1
      harmonicity.searchRegionLength = 5
      harmonicity.maxPeaks = 3
      harmonicity.lpfCoefficient = 0.7
      transient_index = Sirens::TransientIndex.new
      transient_index.mels = 15
      transient_index.filters = 30
    
      [loudness, temporal_sparsity, spectral_sparsity, spectral_centroid, harmonicity, transient_index].each do |feature|
        feature.maxHistorySize = sound_file.frames
      end

      [spectral_centroid, harmonicity, transient_index].each do |feature|
        feature.sampleRate = sound_file.sampleRate
        feature.spectrumSize = sound_file.spectrumSize
      end
        
      features = Sirens::FeatureSet.new
      features.sampleFeatures = [loudness, temporal_sparsity]
      features.spectralFeatures = [spectral_sparsity, spectral_centroid, transient_index, harmonicity]
      sound_file.features = features
      
      # Extract features.
      sound_file.extractFeatures
      sound_file.close
    
      loudness_trajectory = self.features.build
      loudness_trajectory.feature_type = :loudness
      loudness_trajectory.trajectory = loudness.history
    
      temporal_sparsity_trajectory = self.features.build
      temporal_sparsity_trajectory.feature_type = :temporal_sparsity
      temporal_sparsity_trajectory.trajectory = temporal_sparsity.history
    
      spectral_sparsity_trajectory = self.features.build
      spectral_sparsity_trajectory.feature_type = :spectral_sparsity
      spectral_sparsity_trajectory.trajectory = spectral_sparsity.history

      spectral_centroid_trajectory = self.features.build    
      spectral_centroid_trajectory.feature_type = :spectral_centroid
      spectral_centroid_trajectory.trajectory = spectral_centroid.history

      transient_index_trajectory = self.features.build
      transient_index_trajectory.feature_type = :transient_index
      transient_index_trajectory.trajectory = transient_index.history
    
      harmonicity_trajectory = self.features.build
      harmonicity_trajectory.feature_type = :harmonicity
      harmonicity_trajectory.trajectory = harmonicity.history
    
      loudness_trajectory.save
      spectral_sparsity_trajectory.save
      spectral_centroid_trajectory.save
      temporal_sparsity_trajectory.save
      transient_index_trajectory.save
      harmonicity_trajectory.save
    #rescue
    #  return false
    #end
  end
  
  def formatted_lat
    coordinates_text :latitude, self.lat
  end
  
  def formatted_lng
    coordinates_text :longitude, self.lng
  end
  
  def formatted_description
    return textilize(read_attribute(:description))
  end
  
  def formatted_recorded_at
    prettier_time self.recorded_at
  end
end
