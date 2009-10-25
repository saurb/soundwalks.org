module WordnetHelper
  Infinity = 1 / 0.0
  
  # Returns a list of ancestors for a synset, ascending to its unique beginner (e.g. entity)
  def ancestors synset
    ancestors = [synset]
    
    while ancestors.last and ancestors.last.hypernyms.size > 0
      ancestors.push ancestors.last.hypernyms.first
    end
    
    ancestors
  end
  
  # Returns a list of common ancestors between two synsets, ascending.
  def common_ancestors synset1, synset2
    ancestors1 = ancestors(synset1)
    ancestors2 = ancestors(synset2)
    
    ancestors1.reject{|synset| !ancestors2.index(synset)}
  end
  
  def frequency synset
    synset_node = WordnetNode.find(:first, :conditions => {:synset_key => synset.key.to_i})
    return synset_node ? synset_node.frequency : 0
  end
  
  # Computes the probability of encountering the given synset from the frequency table (i.e. p(word | pos(word)).
  def probability synset
    frequency(synset) / WordnetNode.sum(:frequency, :conditions => {:pos => synset.pos, :root => true}).to_f
  end
  
  # Gives the wordsense index of a given synset for its first word.
  def sense synset
    word = synset.words.first
    synsets = word.en.synsets
    
    index = 0
    
    synsets.each_with_index do |synset_sense, i|
      if synset_sense.key == synset.key
        index = i
        break
      end
    end
    
    index
  end
  
  # Computes the Jiang and Conrath distance between two words.
  def jcn_distance word1, word2
    synsets1 = word1.en.synsets
    synsets2 = word2.en.synsets
    
    min_score = Infinity
    
    synsets1.each_with_index do |synset1, i|
      synsets2.each_with_index do |synset2, j|
        score = Infinity
        
        ancestors = common_ancestors(synset1, synset2)
        
        if ancestors.size > 0
          lso = ancestors.first
          
          ic1 = -Math.log(probability(synset1))
          ic2 = -Math.log(probability(synset2))
          iclso = -Math.log(probability(lso))
          
          score = (ic1 + ic2) - (2 * iclso)
        end
        
        min_score = score if min_score > score
      end
    end
    
    min_score
  end
end