# lib/tasks/send_feedback_requests.rake
ENV['PATH'] = '/usr/local/bin:/usr/bin:/bin'

namespace :send_feedback_reminders do
  desc "Envia notificações via email para usuários com chamados 'Aguardando Feedback'"
  task send: :environment do
    Rails.logger.info "Inicio"

    waiting_feedback_status = IssueStatus.find_by(name: 'Aguardando Feedback')
    closed_status = IssueStatus.find_by(name: 'Fechada')
    issues_by_user = Issue.where(status: waiting_feedback_status).group_by(&:author)

    issues_by_user.each do |user, issues|
      issues.each do |issue|
        feedback_count = issue.custom_value_for(CustomField.find_by(name: 'feedback_request_count')).to_s.to_i

        if feedback_count <= 10
          # Adiciona registro de data e hora no log
          log_field = CustomField.find_by(name: 'feedback_request_log')
          log_value = issue.custom_value_for(log_field).to_s
          new_log = "#{Time.now}: Chamado enviado para feedback\n"
          issue.custom_field_values = { log_field.id => (log_value + new_log) }
          issue.save

          # Incrementa o contador de feedback para este chamado
          feedback_count += 1
          issue.custom_field_values = { CustomField.find_by(name: 'feedback_request_count').id => feedback_count.to_s }
          issue.save
        else
          # Caso o chamado tenha mais de 3 envios de feedback, fecha o chamado
          issue.update(status: closed_status)

          note = Journal.new(
            journalized_id: issue.id, # ID do chamado
            journalized_type: 'Issue', # Tipo de entidade (neste caso, Issue)
            user_id: 1, # ID do usuário
            notes: 'Chamado encerrado automaticamente por falta de feedback', # Conteúdo da nota
            private_notes: true # Torna a nota privada
          )

          note.save
        end
      end

      # Envia um email com todos os chamados aguardando feedback para o usuário
      #emails = issues.map { |issue| issue.subject }
      Mailer.send_feedback_email(user, issues).deliver_now
    end
  end
end
