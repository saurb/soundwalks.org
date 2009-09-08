class Study < ActionMailer::Base
  def study(email_params)
    sound_ids = email_params[:tags].collect {|key, value| value}
    sound_names = email_params[:names].collect {|key, value| value}
    
    subject "soundwalks.org study results"
    recipients "study@soundwalks.org"
    from "study@soundwalks.org"
    sent_on Time.now.utc
    
    body :ids => sound_ids, :names => sound_names
  end
end
