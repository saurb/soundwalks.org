class Study < ActionMailer::Base
  def study(email_params)
    subject "soundwalks.org study results"
    recipients "study@soundwalks.org"
    from "study@soundwalks.org"
    sent_on Time.now.utc
    
    body :message => "", :name => ""
  end
end
