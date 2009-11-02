module WordnetHelper
  Infinity = 1 / 0.0
  
  #------------------------------------------------------------------------------------------#
  # Returns a list of ancestors for a synset, ascending to its unique beginner (e.g. entity) #
  #------------------------------------------------------------------------------------------#
  
  def ancestors synset
    ancestors = [synset]
    
    while ancestors.last and ancestors.last.hypernyms.size > 0
      ancestors.push ancestors.last.hypernyms.first
    end
    
    ancestors
  end
  #--------------------------------------------------------------------#
  # Returns a list of common ancestors between two synsets, ascending. #
  #--------------------------------------------------------------------#
  
  def common_ancestors synset1, synset2
    ancestors1 = ancestors(synset1)
    ancestors2 = ancestors(synset2)
    
    ancestors1.reject{|synset| !ancestors2.index(synset)}
  end
  
  #------------------------------------------------------#
  # Returns the frequency of a synset from the database. #
  #------------------------------------------------------#
  
  def synset_frequency synset
    synset_node = WordnetNode.find(:first, :conditions => {:synset_key => synset.key.to_i})
    return synset_node ? synset_node.frequency : 0
  end
  
  #---------------------------------------------------------------------------------------------------------------#
  # Computes the probability of encountering the given synset from the frequency table (i.e. p(word | pos(word)). #
  #---------------------------------------------------------------------------------------------------------------#
  
  def synset_probability synset
    sum = WordnetNode.sum(:frequency, :conditions => {:pos => synset.pos, :root => true})
    return sum > 0 ? synset_frequency(synset) / sum.to_f : 0
  end
  
  #-----------------------------------------------------------------#
  # Gives the wordsense index of a given synset for its first word. #
  #-----------------------------------------------------------------#
  
  def synset_sense synset
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

  #---------------------------------------------------------------------------------------------------------------------------#
  # Computes the Jiang and Conrath distance between two words.                                                                #
  #   See: Jiang, Jay J. and David W. Conrath. 1997. Semantic similarity based on copus statistics and lexical taxonomy.      #
  #     In Proceedings of International Conference on Research in Computational Linguistics (ROCLING X), Taiwan, pages 19-33. #
  #---------------------------------------------------------------------------------------------------------------------------#
  
  def jcn_distance word1, word2
    return 0 if word1 == word2
    
    synsets1 = word1.en.synsets
    synsets2 = word2.en.synsets
    
    min_score = Infinity
    
    for i in 0...synsets1.size
      ic1 = -Math.log(synset_probability(synsets1[i]))
      
      if ic1 < Infinity
        for j in 0...synsets2.size
          ic2 = -Math.log(synset_probability(synsets2[j]))
          
          if ic2 < Infinity
            ancestors = common_ancestors(synsets1[i], synsets2[j])
            
            if ancestors.size > 0
              iclso = -Math.log(synset_probability(ancestors.first))
              score = (ic1 + ic2) - (2 * iclso)
              min_score = score if min_score > score
            end
          end
        end
      end
    end
    
    min_score
  end
  
  #------------------------------------------------------------------------------------------------#
  # Return a similarity value that is 1 / jcn_distance, as in the WordNet::Similarity perl module. #
  #------------------------------------------------------------------------------------------------#
  
  def jcn_similarity word1, word2
    if word1 == word2
      return Infinity
    else
      distance = jcn_distance word1, word2
      return (distance > 0) ? (1 / distance) : Infinity
    end
  end
end