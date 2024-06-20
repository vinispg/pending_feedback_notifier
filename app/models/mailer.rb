class Mailer < ActionMailer::Base
  default from: 'redmine@unochapeco.edu.br'

  def send_feedback_email(user, issues)
    @user = user
    @issues = issues

    mail(to: @user.mail, subject: "Chamados aguardando feedback") do |format|
      format.html { render 'send_feedback_email'}
    end

    Rails.logger.info "Email enviado para #{user.mail}" # Debug
  end
end
