#encoding: utf-8

require 'issues/issues_email_patch'
require 'issues/issues_controller_patch'
require 'wiki/wiki_email_patch'
require 'wiki/wiki_controller_patch'
require 'mailer/mailer_patch'

Redmine::Plugin.register :redmine_send_mails do
  name 'Send Mails plugin'
  author 'Guilherme F. Noronha'
  description 'This is a plugin which sends e-mails only when the user who updates some issue or wiki allows.'
  version '0.0.1'
  author_url 'http://lattes.cnpq.br/9884915193147340'
end

Rails.configuration.to_prepare do
  require_dependency 'issues_controller'
  IssuesController.send(:include, IssueSendParamPatch)    
end

Rails.configuration.to_prepare do
  require_dependency 'issue'
  Issue.send(:include, IssueRecipientPatch)
end

Rails.configuration.to_prepare do
  require_dependency 'wiki_content'
  WikiContent.send(:include, WikiRecipientPatch)
end

Rails.configuration.to_prepare do
  require_dependency 'wiki_controller'
  WikiController.send(:include, WikiSendParamPatch)
end

Rails.configuration.to_prepare do
  require_dependency 'mailer'  
  Mailer.send(:include, MailerControlPatch)
end