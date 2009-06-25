require 'soundwalk'

class Sound < ActiveRecord::Base
  attr_accessor :file
  
  validates_presence_of :recorded_at, :sample_rate, :samples, :frame_size, :hop_size, :spectrum_size, :filename, :frames
  validates_numericality_of :recorded_at, :greater_than => 0
  validates_numericality_of :sample_rate, :greater_than => 0
  validates_numericality_of :samples, :greater_than => 0
  validates_numericality_of :frame_size, :greater_than => 0
  validates_numericality_of :hop_size, :greater_than => 0
  validates_numericality_of :spectrum_size, :greater_than => 0
  validates_numericality_of :frames, :greater_than => 0
  
  def feature_path
    return File.join('public/data/features/', self.filename.split('.')[0] + '.csv')
  end
  
  def sound_path
    return File.join('public/data/sounds/', self.filename)
  end
  
  def before_destroy
    File.delete sound_path
    File.delete feature_path
  end
  
  def before_validation_on_create
    self.filename = file.original_filename
    
    path = sound_path
    File.open(path, 'wb') {|f| f.write(file.read)}
    
    # File properties.
    self.recorded_at = Time.parse(IO.popen("stat -n -f '%SB' #{path}").readlines.first)
    
    # Soundwalk properties.
    sound_file = Soundwalk::Sound.new
    sound_file.frameLength = 0.04
    sound_file.hopLength = 0.02
    sound_file.open path
    
    self.sample_rate = sound_file.sampleRate
    self.samples = sound_file.samples
    self.frame_length = sound_file.frameLength
    self.hop_length = sound_file.hopLength
    self.frame_size = sound_file.samplesPerFrame
    self.hop_size = sound_file.samplesPerHop
    self.spectrum_size = sound_file.spectrumSize
    self.frames = sound_file.frames
  end
  
  def after_create
    sound_file = Soundwalk::Sound.new
    sound_file.frameLength = self.frame_length
    sound_file.hopLength = self.hop_length
    sound_file.open sound_path
    
    print "\n", sound_file
    print "\n\tPath: ", sound_file.path
    print "\n\tSamples: ", sound_file.samples
    print "\n\tSample rate: ", sound_file.sampleRate
    print "\n\tFrame length: ", sound_file.frameLength, "s (", sound_file.samplesPerFrame, " samples)"
    print "\n\tHop length: ", sound_file.hopLength, "s (", sound_file.samplesPerHop, " samples)"
    print "\n\tFFT Size: ", sound_file.fftSize
    print "\n\tSpectrum size: ", sound_file.spectrumSize
    print "\n\n"

    # Initialize features.
    loudness = Soundwalk::LoudnessFeature.new
    temporal_sparsity = Soundwalk::TemporalSparsityFeature.new
    spectral_sparsity = Soundwalk::SpectralSparsityFeature.new
    spectral_centroid = Soundwalk::SpectralCentroidFeature.new

    harmonicity = Soundwalk::HarmonicityFeature.new
    harmonicity.absThreshold = 1
    harmonicity.threshold = 0.1
    harmonicity.searchRegionLength = 5
    harmonicity.maxPeaks = 3
    harmonicity.lpfCoefficient = 0.7

    transient_index = Soundwalk::TransientIndexFeature.new
    transient_index.mels = 15
    transient_index.filters = 30
    
    Array[loudness, temporal_sparsity, spectral_sparsity, spectral_centroid, harmonicity, transient_index].each do |feature|
      feature.historySize = sound_file.frames
    end

    Array[spectral_centroid, harmonicity, transient_index].each do |feature|
      feature.sampleRate = sound_file.sampleRate
      feature.spectrumSize = sound_file.spectrumSize
    end
    
    sound_file.sampleFeatures = Array[loudness, temporal_sparsity]
    sound_file.spectralFeatures = Array[spectral_sparsity, spectral_centroid, transient_index, harmonicity]
    
    # Extract features.
    sound_file.extractFeatures
    
    histories = Array[loudness.history, temporal_sparsity.history, spectral_sparsity.history, spectral_centroid.history, transient_index.history, harmonicity.history]
    
    features_file = File.new(feature_path, 'w')
    for i in 0...sound_file.frames
      histories.each do |history|
        features_file.write(history[i])
        features_file.write(',')
      end
      
      features_file.write("\n")
    end
  end
  
  def trajectory(*args)
    indices = Array.new
    
    args.each do |arg|
      indices.push 0 if arg == :loudness || arg == 'loudness'
      indices.push 1 if arg == :temporal_sparsity || arg == 'temporal_sparsity'
      indices.push 2 if arg == :spectral_sparsity || arg == 'spectral_sparsity'
      indices.push 3 if arg == :spectral_centroid || arg == 'spectral_centroid'
      indices.push 4 if arg == :transient_index || arg == 'transient_index'
      indices.push 5 if arg == :harmonicity || arg == 'harmonicity'
    end
    
    puts indices
    
    trajectory = Array.new(indices.size) { |feature|
      feature = Array.new
    }
    
    File.open(feature_path, 'r').each { |line|
      elements = line.split(',')
      
      for i in 0..(indices.size - 1)
        number = elements[indices[i]].to_f
        
        if !number.nan? && number.finite?
          trajectory[i].push number
        else
          trajectory[i].push 0
        end
      end
    }
    
    return trajectory
  end
end
