class Study < ActionMailer::Base
  def study(email_params)
    subject "[soundwalks.org] " << email_params[:subject]
    recipients "study@soundwalks.org"
    from email_pararms[:email]
    sent_on Time.now.utc
    
    body :message => email_params[:body], :name => email_params[:name]
  end
end
