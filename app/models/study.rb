class Study < ActionMailer::Base
  def study(sound_ids, tags)
    names = []
    
    sounds = Sound.find(:all, :conditions => {:id => sound_ids})
    sounds.each do |sound|
      sound.study_coverage += 1
      names.push sound.filename
      sound.save
    end
    
    subject "soundwalks.org study results #{Time.now.utc}"
    recipients "study@soundwalks.org"
    from "study@soundwalks.org"
    sent_on Time.now.utc
    
    puts sound_ids
    puts names
    puts tags
    
    
    body_text = ""
    for i in 0...names.size
      body_text += "#{names[i]},#{tags[i]}\n"
    end
    
    body :body_text => body_text
  end
end
