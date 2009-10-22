require 'net/http'
require 'open-uri'
require 'xml'

module WordnetRDF
  class NoSynsetError < ArgumentError; end
  
  class Synset
    attr_reader :synsetID, :label, :uri, :gloss, :xml, :part_of_speech, :word_sense

    def Synset.replaceSuffix word, suffices
      possibilities = []
      
      suffices.each do |suffix|
        regexp = Regexp.new("#{suffix.first}$")
        
        if word =~ regexp
          possibilities.push word.gsub(regexp, suffix.second)
        end
      end
      
      possibilities
    end
    
    def Synset.checkExistence(synset)
      begin
        synset = Synset.new('http://www.w3.org/2006/03/wn/wn20/instances/synset-' + synset + '.rdf')
        true
      rescue NoSynsetError
        false
      end
    end
    
    # Needs work ... should probably just use WordNet locally.
    def Synset.detachment word, part_of_speech = 'auto', word_sense = 1
      parts_of_speech = ['noun', 'verb', 'adjective', 'adverb']
      
      noun_suffices = [['s', ''], ['ses', 's'], ['xes', 'x'], ['zes', 'z'], ['ches', 'ch'], ['shes', 'sh'], ['men', 'man'], ['ies', 'y']]
      verb_suffices = [['s', ''], ['ies', 'y'], ['es', 'e'], ['es', ''], ['ed', 'e'], ['ed', ''], ['ing', 'e'], ['ing', ''], ['ning', '']]
      adjective_suffices = [['er', ''], ['est', ''], ['er', 'e'], ['est', 'e']]
      rules = [noun_suffices, verb_suffices, adjective_suffices]
      
      if part_of_speech != "auto"
        possibilities = ["#{word}-#{part_of_speech}-#{word_sense}"]
      else
        possibilities = ["#{word}-noun-#{word_sense}", "#{word}-verb-#{word_sense}", "#{word}-adjective-#{word_sense}", "#{word}-adverb-#{word_sense}"]
      end
      
      rules.each_with_index do |rule, i|
        if part_of_speech == parts_of_speech[i] or part_of_speech == 'auto'
          Synset.replaceSuffix(word, rule).each do |new_word|
            parts_of_speech.each do |new_part|
              possibilities.push "#{new_word}-#{new_part}-1"
            end
          end
        end
      end
      
      possibilities.each do |possibility|
        parts = possibility.split('-')
        return {'word' => parts[0..parts.size - 3].join('-'), 'part_of_speech' => parts[parts.size - 2], 'word_sense' => parts[parts.size - 1]} if Synset.checkExistence(possibility)
      end
      
      nil
    end
    
    def Synset.getLCS synset1, synset2
      ancestors1 = synset1.ancestors
      ancestors2 = synset2.ancestors
      
      ancestors1.each do |ancestor1|
        ancestors2.each do |ancestor2|
          return ancestor1 if ancestor1.synsetID == ancestor2.synsetID
        end
      end

      nil
    end
    
    def initialize(word, part_of_speech = nil, word_sense = 1)
      if part_of_speech.nil?
        @uri = word
        
        synset_parts = @uri.split('/').last.split('.').first.split('-')
        
        @part_of_speech = synset_parts[synset_parts.size - 2]
        @word_sense = synset_parts[synset_parts.size - 1]
      else
        part_of_speech = 'auto' if part_of_speech.nil?
        
        word = word.gsub(/[ \t\r\n\v\f]/, '_')
        
        results = Synset.detachment(word, part_of_speech, word_sense)
        
        if results
          word = results['word']
          @part_of_speech = results['part_of_speech']
          @word_sense = results['word_sense']
          
          @uri = "http://www.w3.org/2006/03/wn/wn20/instances/synset-#{word}-#{@part_of_speech}-#{@word_sense}.rdf"
        else
          raise NoSynsetError, "Could not find synset for word: #{word}", caller
        end
      end
      
      initializeAttributes
    end
    
    def initializeAttributes
      parsed_uri = URI.parse(@uri)
      
      request = Net::HTTP::Get.new(parsed_uri.path)
      response =  Net::HTTP.start(parsed_uri.host, parsed_uri.port) {|http| http.request(request)}
      
      if response and response.code == '200'
        parser = XML::Parser.string(response.body)
      
        @xml = parser.parse
        @label = parseLabel()
        @synsetID = parseID()
        @gloss = parseGloss()
      else
        raise NoSynsetError, "Could not find synset: #{@uri}", caller
      end
    end
    
    def wordSenses
      nodes = @xml.find('//wn20schema::containsWordSense', 'http://www.w3.org/2006/03/wn/wn20/schema/')
      nodes.collect{|node| WordSense.new(node['resource'])}
    end
    
    def ancestor
      nodes = @xml.find('//wn20schema:hyponymOf', 'http://www.w3.org/2006/03/wn/wn20/schema/')
      return Synset.new(nodes.first['resource'] + '.rdf') if nodes.size > 0
      nil
    end
    
    def ancestors
      ancestors = [self]
      
      begin
        ancestor = ancestors.last.ancestor
        ancestors.push ancestor if !ancestor.nil?
      end while ancestor
      
      ancestors
    end
    
    protected
    def parseLabel
      nodes = @xml.find('//rdfs:label')
      @label = nodes.size > 0 ? nodes.first.content : nil
    end
    
    def parseID
      nodes = @xml.find('//wn20schema:synsetId', 'http://www.w3.org/2006/03/wn/wn20/schema/')
      @synsetID = nodes.size > 0 ? nodes.first.content : nil
    end
    
    def parseGloss
      nodes = @xml.find('//wn20schema:gloss', 'http://www.w3.org/2006/03/wn/wn20/schema/')
      @gloss = nodes.size > 0 ? nodes.first.content : nil
    end
  end
end