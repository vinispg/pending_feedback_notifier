Redmine::Plugin.register :pending_feedback_notifier do
  name 'Pending Feedback Notifier plugin'
  author 'Vinicios Spigiorin'
  description 'Plugin de notificação diária via email para chamados com o status Aguardando Feedback'
  version '1.0.0'
  url 'https://github.com/vinispg/pending_feedback_notifier'
  author_url 'https://github.com/vinispg'
end

#define o path do rake
Dir.glob(File.expand_path("../../plugins/pending_feedback_notifier/lib/tasks/*.rake", __FILE__)).each { |r| import r }

