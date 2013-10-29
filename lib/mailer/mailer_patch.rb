#encoding: utf-8

require_dependency 'mailer'

module MailerControlPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :issue_edit, :send_mail_control
      alias_method_chain :issue_add, :send_mail_control
      alias_method_chain :wiki_content_updated, :send_mail_control
    end
  end
end

module InstanceMethods
  def issue_edit_with_send_mail_control(journal)

    issue = journal.journalized.reload
    redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id journal
    references issue
    @author = journal.user
    recipients = issue.recipients
    # Watchers in cc
    cc = issue.watcher_recipients - recipients
    s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    s << "(#{issue.status.name}) " if journal.new_value_for('status_id')
    s << issue.subject
    @issue = issue
    @journal = journal
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
    if @issue.get_mail_checker_issue.nil?
      recipients = []
      cc = []
    end
    mail :to => recipients,
        :cc => cc,
        :subject => s
  end
  
    def issue_add_with_send_mail_control(issue)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id issue
    @author = issue.author
    @issue = issue
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)
    recipients = issue.recipients
    cc = issue.watcher_recipients - recipients
    if @issue.get_mail_checker_issue.nil?
      recipients = []
      cc = []
    end    
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
  end

  def wiki_content_updated_with_send_mail_control(wiki_content)
    redmine_headers 'Project' => wiki_content.project.identifier,
                    'Wiki-Page-Id' => wiki_content.page.id
    @author = wiki_content.author
    message_id wiki_content
    recipients = wiki_content.recipients
    cc = wiki_content.page.wiki.watcher_recipients + wiki_content.page.watcher_recipients - recipients
    @wiki_content = wiki_content
    @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                      :project_id => wiki_content.project,
                                      :id => wiki_content.page.title)
    @wiki_diff_url = url_for(:controller => 'wiki', :action => 'diff',
                                   :project_id => wiki_content.project, :id => wiki_content.page.title,
                                   :version => wiki_content.version)
    if @wiki_content.get_mail_checker_wiki.nil?
      recipients = []
      cc = []
    end
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{wiki_content.project.name}] #{l(:mail_subject_wiki_content_updated, :id => wiki_content.page.pretty_title)}"
  end
  

end

Rails.configuration.to_prepare do
  Mailer.send(:include, MailerControlPatch)
end