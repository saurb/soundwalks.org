require 'gchart'

module SoundHelper
  #-----------------------------------------------#
  # Displays a line chart of an acoustic feature. #
  #-----------------------------------------------#
  
  def feature_chart(title, data, color)
    image_tag Gchart.line(
  		:size => '400x75',
  		:title => title, 
  		:bar_colors => color,
  		:axis_with_labels => 'x,y',
  		:axis_labels => [("0|" + data.length.to_s), '0|1'],
  		:bg => 'FFFFFF00',
  	  :data => data,
  		:max_value => 1.0)
  end
  
  #------------------#
  # Marker for maps. #
  #------------------#
  
  def medium_marker_icon
    return GoogleMapIcon.new(:anchor_x => 16, :anchor_y => 16, :width => 32, :height => 32, :shadow_width => 0, :shadow_height => 0, :image_url => '/images/big_marker_75.png')
  end
  
  #----------------------------------------------------------#
  # Opens a sound file as a sirens-ruby object for analysis. #
  #----------------------------------------------------------#
  
  def open_sound file, frame_length = 0.04, hop_length = 0.02
    sound_file = Sirens::Sound.new
    sound_file.frameLength = frame_length
    sound_file.hopLength = hop_length
    
    return sound_file.open(file) ? sound_file : nil
  end
  
  #---------------------------------------------#
  # Extracts feature trajectories from a sound. #
  #---------------------------------------------#
  
  def sound_features sound_file
    puts "\tCreating feature objects."
    loudness = Sirens::Loudness.new
    temporal_sparsity = Sirens::TemporalSparsity.new
    spectral_sparsity = Sirens::SpectralSparsity.new
    spectral_centroid = Sirens::SpectralCentroid.new
    harmonicity = Sirens::Harmonicity.new
    transient_index = Sirens::TransientIndex.new

    puts "\tSetting normalization parameters."
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

    puts "\tSetting history size."
    [loudness, temporal_sparsity, spectral_sparsity, spectral_centroid, harmonicity, transient_index].each do |feature|
      feature.maxHistorySize = sound_file.frames
    end
    
    puts "\tSetting sample rate and spectrum size."
    [spectral_centroid, harmonicity, transient_index].each do |feature|
      feature.sampleRate = sound_file.sampleRate
      feature.spectrumSize = sound_file.spectrumSize
    end

    puts "\tCreating feature set."
    feature_set = Sirens::FeatureSet.new

    puts "\tAdding sample features to feature set."
    [loudness, temporal_sparsity].each do |feature|
      feature_set.addSampleFeature feature
    end
    
    puts "\tAdding spectral features to feature set."
    [spectral_sparsity, spectral_centroid, transient_index, harmonicity].each do |feature|
      feature_set.addSpectralFeature feature
    end
    
    puts "\tAttaching feature set to sound object."
    sound_file.featureSet = feature_set
    
    # Extract features.
    puts "\tExtracting features."
    sound_file.extractFeatures
    
    puts "\tReturning features."
    {
      :loudness => loudness,
      :temporal_sparsity => temporal_sparsity,
      :spectral_sparsity => spectral_sparsity,
      :spectral_centroid => spectral_centroid,
      :transient_index => transient_index,
      :harmonicity => harmonicity
    }
  end
  
  #-----------------------------------------------------------------#
  # Segments a sound and returns segment start times and durations. #
  #-----------------------------------------------------------------#
  
  def sound_segments features
    loudness = features[:loudness]
    spectral_sparsity = features[:spectral_sparsity]
    spectral_centroid = features[:spectral_centroid]
    
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
    
    segmenter = Sirens::Segmenter.new
    segmenter.featureSet = feature_set
    segmenter.pNew = 0.00000000001
    segmenter.pOff = 0.00000000001
    
    segmenter.segment
    segmenter.segments
  end
  
  #-----------------------------------------------------------#
  # Print diagnostic information about a sirens sound object. #
  #-----------------------------------------------------------#
  
  def sound_stats sound
    stats = "#{sound.path} (#{sound})
      \tSamples: #{sound.samples}
      \tFrames: #{sound.frames}
      \tSample rate: #{sound.sampleRate}
      \tFrame length: #{sound.frameLength}
      \tHop length: #{sound.hopLength}
      \tFrame size: #{sound.samplesPerFrame}
      \tHop size: #{sound.samplesPerHop}
      \tSpectrum size: #{sound.spectrumSize}
      \tFFT size: #{sound.fftSize}"
  end
end

