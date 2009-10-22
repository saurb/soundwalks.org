namespace :tags do
  #------------------------------------------------------------------------------------------------------#
  # tags:wordnet: Select a default part of speech for each tag in the database and assign its synset ID. #
  #------------------------------------------------------------------------------------------------------#  
  desc "Select a default part of speech for each tag in the database and assign its synset ID."
  
  task :wordnet => :environment do
    tags = Tag.find(:all)
    
    puts 'Upating tags.'
    tags.each_with_index do |tag, i|
      synset = nil
      synset_part_of_speech = nil
      
      begin
        synset = WordnetRDF::Synset.new(tag.name, 'auto')
      rescue WordnetRDF::NoSynsetError
        puts "\t#{i} / #{tags.size}: #{tag.name} (not found)"
        synset = nil
      end
      
      if !synset.nil?
        tag.synset_id = synset.synsetID
        tag.part_of_speech = synset.part_of_speech
        tag.word_sense = synset.word_sense
        tag.synset_label = synset.label
        
        tag.save
        
        puts "\t#{i} / #{tags.size}: #{tag.name}: #{tag.synset_label}-#{tag.part_of_speech}-#{tag.word_sense} (#{tag.synset_id})"
      end
    end
    
    Settings.tags_parts_of_speech = 1
  end
end
