module WordnetHelper
#  lexicon = Wordnet::Lexicon.new
#  
#  def wordnet_similarity(a, b)
#    max_similarity = 0
#    
#    parts_of_speech = [WordNet::Noun, WordNet::Adjective, WordNet::Verb, WordNet::Adverb]
#    
#    parts_of_speech.each do |part_of_speech|
#      synsets_a = lexicon.lookupSynset(a, part_of_speech)
#      synsets_b = lexicon.lookupSynset(b, part_of_speech)
#      
#      if synsets_a != nil && synsets_a.size > 0 && synsets_b != nil && synsets_b.size > 0
#        synsets_a.each do |synset_a|
#          synsets_b.each do |synset_b|
#            words_a = synset_a.words
#            words_b = synset_b.words
#            all_words = (words_a + words_b).uniq
#            
#            total = 0
#            
#            words_a.collect{|word| total += 1 if words_b.index(word)}
#            
#            similarity = total.to_f / all_words.size.to_f
#            
#            max_similarity = similarity if (similarity > max_similarity)
#          end
#        end
#      end
#    end
#    
#    return max_similarity
#  end
end