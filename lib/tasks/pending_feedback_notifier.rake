# namespace :send_feedback_reminders do
#   desc "Envia notificações via email para usuários com chamados 'Aguardando Feedback'"
#   task send: :environment do
#     Issue.where(status: Status.find_by(name: 'Aguardando Feedback')).each do |issue|
#       user = issue.author
#       Mailer.feedback_email(user, issue).deliver_now
#     end
#   end
# end

# lib/tasks/send_feedback_requests.rake
ENV['PATH'] = '/usr/local/bin:/usr/bin:/bin'
namespace :send_feedback_reminders do
  desc "Envia notificações via email para usuários com chamados 'Aguardando Feedback'"
  task send: :environment do
    Rails.logger.info "Inicio"

    waiting_feedback_status = IssueStatus.find_by(name: 'Aguardando Feedback')
    Rails.logger.info "waiting #{waiting_feedback_status}"

    closed_status = IssueStatus.find_by(name: 'Fechado')
    Rails.logger.info "closed #{closed_status}"

    issues_by_user = Issue.where(status: waiting_feedback_status).group_by(&:author)
    Rails.logger.info "issues_by_user #{issues_by_user}"

    issues_by_user.each do |user, issues|
      feedback_count = issues.first.custom_field_value(CustomField.find_by(name: 'feedback_request_count')).to_i
      Rails.logger.info "feedback_count #{feedback_count}"

      if feedback_count < 3
        Rails.logger.info "PARAMETROS PARA O EMAIL #{user} issues #{issues}"

        userObj = issues.first.author
        Rails.logger.info "OBJETO USUARIO #{userObj.mail}"
        # Envie o email com a lista de chamados
        Mailer.send_feedback_email(userObj, "teste").deliver_now

        # Atualize o campo personalizado para cada chamado
        issues.each do |issue|
          issue.custom_field_values = { CustomField.find_by(name: 'feedback_request_count').id => (feedback_count + 1).to_s }
          issue.save
        end
      elsif feedback_count >= 3
        # Verifique se é sábado ou domingo
        if ![0, 6].include?(Time.now.wday) # 0 para Domingo, 6 para Sábado
          # Mude o status dos chamados para "Fechado"
          issues.each do |issue|
            issue.update(status: closed_status)
          end
        end
      end
    end
  end
end