require 'sirens'

class Sound < ActiveRecord::Base
  include AASM
  
  belongs_to :soundwalk
  belongs_to :user
  
  aasm_column :state
  aasm_initial_state :calculated
  aasm_state :created
  aasm_state :calculated
  
  aasm_event :calculate do
    transitions :from => :created, :to => :calculated
  end
  
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
  end
  
  validates_as_attachment
  validates_presence_of :lat, :lng, :recorded_at
  
  serialize :features, Hash
  
  def localize
    point = self.soundwalk.interpolate(self.recorded_at)
      
    self.lat = point.first
    self.lng = point.second
  end
  
  def analyze_sound
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
