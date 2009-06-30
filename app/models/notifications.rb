class Notifications < ActionMailer::Base
  def forgot_password(to, login, pass, sent_at = Time.now)
    @subject    = "Your password is ..."
    @body['login'] = login
    @body['pass'] = pass
    @recipients = to
    @from       = 'support@cherem.org'
    @sent_on    = sent_at
    @headers    = {}
  end
end
