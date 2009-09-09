class Study < ActionMailer::Base
  def study(sound_ids, tags)
    names = Array.new(sound_ids.size, "")
    sound_ids = sound_ids.collect {|id| id.to_i }
    
    sounds = Sound.find(:all, :conditions => {:id => sound_ids})
    sounds.each do |sound|
      sound.study_coverage += 1
      names[sound_ids.index(sound.id)] = sound.filename
      sound.save
    end
    
    subject "soundwalks.org study results #{Time.now.utc}"
    recipients "study@soundwalks.org"
    from "study@soundwalks.org"
    sent_on Time.now.utc
    
    for i in 0...tags.size
      tags[i] = tags[i].split(",")
      for j in 0...tags[i].size
        tags[i][j] = tags[i][j].strip
      end
      tags[i] = tags[i].join(",")
    end
    
    body_text = ""
    for i in 0...names.size
      body_text += "#{names[i]},#{tags[i]}\n"
    end
    
    body :body_text => body_text
  end
end
