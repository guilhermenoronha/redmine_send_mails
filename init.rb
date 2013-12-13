#encoding: utf-8

require 'issues/issues_email_patch'
require 'wiki/wiki_email_patch'
require 'wiki/wiki_controller_patch'
require 'mailer/mailer_patch'
require 'user/user_preference_patch'

require 'issues/controller_hook'
require_dependency 'issues/view_hook'

Redmine::Plugin.register :redmine_send_mails do
  name 'Send Mails plugin'
  author 'Guilherme F. Noronha'
  description 'This is a plugin which sends e-mails only when the user who updates some issue or wiki allows.'
  version '0.3.23xBeta'
  author_url 'http://lattes.cnpq.br/9884915193147340'
end