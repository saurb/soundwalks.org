module WordnetRDF
  class WordSense
    attr_reader :uri, :tagCount, :label, :xml
    
    def initialize(word, part_of_speech = nil, word_sense = 1)
      if part_of_speech.nil?
        @uri = word
      else
        part_of_speech = 'noun' if part_of_speech == 'auto'
        @uri = "http://www.w3.org/2006/03/wn/wn20/instances/synset-#{word}-#{part_of_speech}-#{word_sense}"
      end
      
      initializeAttributes
    end

    def initializeAttributes
      parser = XML::Parser.file(@uri)
      
      if parser
        @xml = parser.parse
        @label = parseLabel();
        @tagCount = parseTagCount();
      else
        raise "Cannot find Wordsense (#{@uri})."
      end
    end
    
    def synset
      Synset.new(@uri.gsub(/wordsense/, 'synset'))
    end
    
    protected
    
    def parseLabel
      nodes = @xml.find('//rdfs:label')
      @label = nodes.size > 0 ? nodes.first.content : nil
    end
    
    def parseTagCount
      nodes = @xml.find('//wn20schema:tagCount')
      @tagCount = nodes.size > 0 ? nodes.first.content : nil
    end
  end
end
