module Redmine_send_emails
  module Hooks
    class Issues_controller_hook < Redmine::Hook::ViewListener
      def controller_issues_new_before_save(context={})
        context[:issue].mail_checker_issue = context[:params][:mail_checker_issue]
      end
      
      def controller_issues_bulk_edit_before_save(context={})
        context[:issue].mail_checker_issue = context[:params][:mail_checker_issue]
      end
      
      def controller_issues_edit_before_save(context={})
        context[:issue].mail_checker_issue = context[:params][:mail_checker_issue]
      end
    end
  end
end