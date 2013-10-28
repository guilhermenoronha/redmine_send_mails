#encoding: utf-8

require_dependency 'issue'

module IssueRecipientPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end
end

module InstanceMethods

    def set_mail_checker_issue(mail)
      @mail_checker = mail
    end
    
    def get_mail_checker_issue
      @mail_checker
    end
end

Rails.configuration.to_prepare do
  Issue.send(:include, IssueRecipientPatch)
end