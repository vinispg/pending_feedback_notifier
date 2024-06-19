class Mailer < ActionMailer::Base
  default from: 'redmine@unochapeco.edu.br'

  def send_feedback_email(user, subject)
    @user = user

    mail(to: @user.mail, subject: subject) do |format|
      format.html { render 'send_feedback_email' }  # Renderiza o template send_feedback_email.html.erb
    end
    Rails.logger.info "Email enviado para #{@user.mail}" # Debug
  end
end