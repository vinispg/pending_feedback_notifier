class Mailer < ActionMailer::Base
  default from: 'redmine@unochapeco.edu.br'

  def send_feedback_email(user, issues)
    @user = user
    @issues_with_counts = issues.map do |issue|
      feedback_count = issue.custom_value_for(CustomField.find_by(id: 1)).to_s.to_i
      { issue: issue, feedback_count: feedback_count }
    end

    mail(to: @user.mail, subject: "Chamados aguardando feedback") do |format|
      format.html { render 'send_feedback_email'}
    end

    Rails.logger.info "Email enviado para #{user.mail}" # Debug
  end
end
