require 'matrix'
require 'pqueue'

Infinity = 1.0 / 0.0

# Why Matrix isn't built with this is beyond me.
class Matrix
  def []=(i,j,x)
    @rows[i][j] = x
  end
end

# Normalize a log-likelihood similarity matrix to be a scaled distance matrix.
def normalize_affinity(matrix)
  ones = Matrix.row_vector(Array.new(matrix.row_size) {1})
  diag = Matrix.column_vector(Array.new(matrix.row_size) {|i| matrix[i, i]})
  
  (diag * ones) + (ones.transpose * diag.transpose) - matrix - matrix.transpose
end

namespace :links do
  desc "Calculates link costs between sounds in the network."
  task :sound_to_sound => :environment do
    sounds = Sound.find(:all)
    sound_ids = sounds.collect{|sound| sound.id}
    log_probability = Matrix.rows(Array.new(sounds.size) {Array.new(sounds.size) {Infinity}})
    
    puts "Computing similarities."
    # Compute log-probabilities for link costs.
    for i in 0...sounds.size
      comparator = sounds[i].get_comparator
      
      for j in i...sounds.size        
        value = sounds[i].compare(sounds[j], comparator)
        
        if !value.nan?
          log_probability[i, j] = value
          log_probability[j, i] = value
        else
          value = Math.log(0)
          log_probability[i, j] = value
          log_probability[j, i] = value
        end
        
        puts "\t(#{i}, #{j}) = #{value}"
      end
    end
    
    puts "Creating normalizd affinity matrix."
    # Compute log-scale normalized distance matrix.
    affinity = normalize_affinity(log_probability)
    
    puts "Updating links."
    # Update link costs.
    for i in 0...affinity.row_size
      for j in i...affinity.column_size
        puts "\t(#{i}, #{j})"
        
        if !affinity[i, j].nan? && (affinity[i, j] != Infinity) && (affinity[i, j] != -Infinity)
          update_or_create_link(sounds[i], sounds[j], affinity[i, j], nil)
          update_or_create_link(sounds[j], sounds[i], affinity[i, j], nil)
        end
      end
    end
  end
  
  desc "Calculates link costs between tags in the network."
  task :tag_to_tag => :environment do
    @tags = Tag.find(:all)
    
    @tags.each do |first|
      @tags.each do |second|
        update_or_create_link(first, second, Infinity, nil)
        update_or_create_link(second, first, Infinity, nil)
      end
    end
  end
  
  desc "Calculates link costs between sounds and tags in the network."
  task :sound_to_tag => :environment do
    @sounds = Sound.find(:all)
    
    # Compute log-probability for each link.
    @sounds.each do |sound|
      tags = sound.tag_counts_on(:tags)
      total = sound.taggings.collect{|tagging| tagging.tagger}.uniq.size
      
      tags.each do |tag|
        value = -Math.log(tag.count.to_f / total.to_f)
        
        update_or_create_link(sound, tag, value, nil)
        update_or_create_link(tag, sound, value, nil)
      end
    end
  end
  
  desc "Computes shortest path distances between nodes in the network."
  task :recalculate_distances => :environment do
    sounds = Sound.find(:all)
    tags = Tag.find(:all)
    nodes = sounds + tags
    
    # Compute edge and weight matrices.
    edges = Array.new(nodes.size) {[]}
    weights = Matrix.rows(Array.new(nodes.size){Array.new(nodes.size, Infinity)})
    
    # Fill sound-sound weights.
    for i in 0...sounds.size
      for j in i...sounds.size
        links = Link.find_with_nodes(sounds[i], sounds[j])
        if links != nil && links.size > 0
          edges[i].push j
          weights[i, j] = links.first.cost
          weights[j, i] = links.first.cost
        end
      end
    end
    
    # Fill sound-tag weights.
    for i in 0...sounds.size
      for j in 0...tags.size
        links = Link.find_with_nodes(sounds[i], tags[j])
        
        if links != nil && links.size > 0
          edges[i].push j + sounds.size
          weights[i, j + sounds.size] = links.first.cost
          weights[i + sounds.size, j] = links.first.cost
        end
      end
    end
    
    puts weights
        
    # Dijkstra.
    nodes.each_with_index do |source_node, source_index|
      # Create all the necessary arrays.
      visited = Array.new(nodes.size, false)
      shortest_distances = Array.new(nodes.size, Infinity)
      previous = Array.new(nodes.size, nil)
      queue = PQueue.new(proc {|x,y| shortest_distances[x] < shortest_distances[y]})
      
      # Initialize.
      queue.push(source_index)
      visited[source_index] = true
      shortest_distances[source_index] = 0
      
      while queue.size != 0
        v = queue.pop
        visited[v] = true
        if edges[v]
          edges[v].each do |w|
            if !visited[w] and shortest_distances[w] > shortest_distances[v] + weights[v, w]
              shortest_distances[w] = shortest_distances[v] + weights[v, w]
              previous[w] = v
              queue.push w
            end
          end
        end
      end
      
      shortest_distances.each_with_index do |distance, i|
        update_or_create_link(nodes[source_index], nodes[i], nil, distance) if distance < Infinity
      end
    end
  end
end
