require 'sirens'

class Sound < ActiveRecord::Base
  belongs_to :soundwalk
  belongs_to :user
  
  acts_as_taggable_on :tags
  acts_as_mappable
  
  serialize :features, Hash
  
  attr_accessor :sound_file
  
  validates_presence_of :recorded_at, :sample_rate, :samples, 
    :frame_size, :hop_size, :spectrum_size, :frame_length, 
    :hop_length, :filename, :frames
    
  validates_numericality_of :sample_rate, :greater_than => 0
  validates_numericality_of :samples, :greater_than => 0
  validates_numericality_of :frame_size, :greater_than => 0
  validates_numericality_of :hop_size, :greater_than => 0
  validates_numericality_of :frame_length, :greater_than => 0
  validates_numericality_of :hop_length, :greater_than => 0
  validates_numericality_of :spectrum_size, :greater_than => 0
  validates_numericality_of :frames, :greater_than => 0
  
  def feature_path
    return File.join('public/data/features/', self.filename.split('.')[0] + '.csv')
  end
  
  def sound_path
    return File.join('public/data/sounds/', self.filename)
  end
  
  def before_destroy
    begin
      File.delete sound_path
    rescue
    end
  end
  
  def before_validation_on_create
    self.filename = sound_file.original_filename
    
    path = sound_path
    File.open(path, 'wb') {|f| f.write(sound_file.read)}
    
    #puts "Recorded at: " + self.recorded_at
    
    analyze_sound
    
    if (!self.lat || !self.lng) && self.recorded_at && self.soundwalk
      point = self.soundwalk.interpolate(self.recorded_at)
      
      self.lat = point.first
      self.lng = point.second
    end
  end
  
  def analyze_sound
    sound_file = Sirens::Sound.new
    sound_file.frameLength = 0.04
    sound_file.hopLength = 0.02
    sound_file.open sound_path
     
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
    
    sound_file.sampleFeatures = Array[loudness, temporal_sparsity]
    sound_file.spectralFeatures = Array[spectral_sparsity, spectral_centroid, transient_index, harmonicity]
    
    # Extract features.
    sound_file.extractFeatures
    sound_file.close
    
    self.features = {
      :loudness => loudness.history, 
      :temporal_sparsity => temporal_sparsity.history,
      :spectral_sparsity => spectral_sparsity.history,
      :spectral_centroid => spectral_centroid.history,
      :transient_index => transient_index.history,
      :harmonicity => harmonicity.history
    }
  end
end
