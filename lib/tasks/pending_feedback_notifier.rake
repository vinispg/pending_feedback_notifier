namespace :send_feedback_reminders do
  desc "Envia notificações via email para usuários com chamados 'Aguardando Feedback'"
  task send: :environment do
    Issue.where(status: Status.find_by(name: 'Aguardando Feedback')).each do |issue|
      user = issue.author
      Mailer.feedback_email(user, issue).deliver_now
    end
  end
end