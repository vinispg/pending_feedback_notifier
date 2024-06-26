# lib/tasks/send_feedback_requests.rake
ENV['PATH'] = '/usr/local/bin:/usr/bin:/bin'

namespace :send_feedback_reminders do
  desc "Envia notificações via email para usuários com chamados 'Aguardando Feedback'"
  task send: :environment do

    AGUARDANDO_FEEDBACK = 4
    PROJETO_CHAMADOS = 1
    FEEDBACK_COUNT = 1
    FEEDBACK_LOGS = 2
    RESOLVIDO = 5
    DOMINGO = 0
    SABADO = 6

    # Verifica o dia da semana. 0 = Domingo, 6 = Sábado, se for fim de semana, não faz nada
    today = Time.now.wday
    if today == DOMINGO || today == SABADO
      Rails.logger.info "Hoje é fim de semana :D. Nenhuma ação será realizada."
      next
    end

    waiting_feedback_status = IssueStatus.find_by(id: AGUARDANDO_FEEDBACK)
    closed_status = IssueStatus.find_by(id: RESOLVIDO)
    project_id = Project.find_by(id: PROJETO_CHAMADOS)

    issues_by_user = Issue.where(status: waiting_feedback_status, project_id: project_id.id).group_by(&:author)

    issues_by_user.each do |user, issues|
      issues.each do |issue|
        feedback_count = issue.custom_value_for(CustomField.find_by(id: FEEDBACK_COUNT)).to_s.to_i

        if feedback_count <= 2
          # Adiciona registro de data e hora no log
          log_field = CustomField.find_by(id: FEEDBACK_LOGS)
          log_value = issue.custom_value_for(log_field).to_s
          new_log = "#{Time.now}: Chamado enviado para feedback\n"
          issue.custom_field_values = { log_field.id => (log_value + new_log) }
          issue.save

          # Incrementa o contador de feedback para este chamado
          feedback_count += 1
          issue.custom_field_values = { CustomField.find_by(id: FEEDBACK_COUNT).id => feedback_count.to_s }
          issue.save
        else
          # Caso o chamado tenha mais de 3 envios de feedback, fecha o chamado
          issue.update(status: closed_status)

          note = Journal.new(
            journalized_id: issue.id,
            journalized_type: 'Issue',
            user_id: 1,
            notes: 'Chamado encerrado automaticamente por falta de feedback',
            private_notes: true
          )

          note.save
        end
      end

      # Envia um email com todos os chamados aguardando feedback para o usuário
      Mailer.send_feedback_email(user, issues).deliver_now
    end
  end
end
