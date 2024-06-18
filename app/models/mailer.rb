class Mailer < ActionMailer::Base
  default from: 'redmine@unochapeco.edu.br'
  def feedback_email(user, issue)
    @user = user
    @issue = issue

    mail(to: @user.mail, subject: "Chamado ##{@issue.id} - #{@issue.subject} aguardando feedback #{@user.name}") do |format|
      format.html { render 'feedback_email' }  # Renderiza o template feedback_email.html.erb
    end
    Rails.logger.info "Email enviado para #{@user.mail}" #Debug
  end
end