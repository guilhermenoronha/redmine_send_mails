#encoding: utf-8

require_dependency 'issues_controller'

module IssueSendParamPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        alias_method_chain :update, :send_mail_checker_issues
      end
    end
end

module InstanceMethods
  def update_with_send_mail_checker_issues
    return unless update_issue_from_params
    @issue.save_attachments(params[:attachments] || (params[:issue] && params[:issue][:uploads]))
    saved = false
    begin
      @issue.set_mail_checker_issue(params[:mail_checker_issue])
      saved = @issue.save_issue_with_child_records(params, @time_entry)
    rescue ActiveRecord::StaleObjectError
      @conflict = true
      if params[:last_journal_id]
        if params[:last_journal_id].present?
          last_journal_id = params[:last_journal_id].to_i
          @conflict_journals = @issue.journals.all(:conditions => ["#{Journal.table_name}.id > ?", last_journal_id])
        else
          @conflict_journals = @issue.journals.all
        end
      end
    end

    if saved
      render_attachment_warning_if_needed(@issue)
      flash[:notice] = l(:notice_successful_update) unless @issue.current_journal.new_record?

      respond_to do |format|
        format.html { redirect_back_or_default({:action => 'show', :id => @issue}) }
        format.api  { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@issue) }
      end
    end
  end
end

Rails.configuration.to_prepare do
  IssuesController.send(:include, IssueSendParamPatch)
end