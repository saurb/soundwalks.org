namespace :tags do
  desc "Tags sounds with several dummy users according to a specially formatted CSV file."
  task :load => :environment do
    file = File.open(File.join(RAILS_ROOT, ENV['TAGGING_FILE']))

    file.each_line do |line|
      puts line
      components = line.split(',')
      
      if components.size > 2
        user = User.find(:first, :conditions => {:login => "dummy#{components[0]}"})
        
        if user
          sound = Sound.find(:first, :conditions => {:filename => components[1]})
          
          if sound
            user.tag(sound, :with => components[2...components.size].join(','), :on => :tags)
            
            puts "\t[Success] User #{user.id} tagged sound #{sound.id} with #{components[2...components.size].join(',')}"
          else
            puts "\t[Error] Couldn't find sound: #{components[1]}"
          end
        else
          puts "\t[Error] Couldn't find user: dummy#{components[0]}"
        end
      end
    end
  end
end
