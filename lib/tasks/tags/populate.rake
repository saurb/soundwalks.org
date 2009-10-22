namespace :tags do
  #---------------------------------------------------------------------------------------------#
  # tags:populate: Add a tag for each word in WordNet. Choose synsets with highest frequencies. #
  #---------------------------------------------------------------------------------------------#  
  desc "Adds a tag to the database for each word in WordNet. Chooses synsets with highest frequencies in a corpus."
  
  task :populate => :environment do
    Settings.tags_populate = 1
  end
end
