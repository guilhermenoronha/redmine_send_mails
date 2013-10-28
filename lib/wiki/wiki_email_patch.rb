#encoding: utf-8

require_dependency 'wiki_content'

module WikiRecipientPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end
end

module InstanceMethods

    def set_mail_checker_wiki(mail)
      @mail_checker_wiki = mail
    end
    
    def get_mail_checker_wiki
      @mail_checker_wiki
    end
    
end

Rails.configuration.to_prepare do
  WikiContent.send(:include, WikiRecipientPatch)
end