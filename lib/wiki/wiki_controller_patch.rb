#encoding: utf-8

require_dependency 'wiki_controller'
require_dependency 'issues_controller'

module WikiSendParamPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        alias_method_chain :update, :send_mail_checker_wiki
      end
    end
end

module InstanceMethods
  def update_with_send_mail_checker_wiki
    return render_403 unless editable?
    was_new_page = @page.new_record?
    @page.content = WikiContent.new(:page => @page) if @page.new_record?
    @page.safe_attributes = params[:wiki_page]

    @content = @page.content
    content_params = params[:content]
    if content_params.nil? && params[:wiki_page].is_a?(Hash)
      content_params = params[:wiki_page].slice(:text, :comments, :version)
    end
    content_params ||= {}

    @content.comments = content_params[:comments]
    @text = content_params[:text]
    if params[:section].present? && Redmine::WikiFormatting.supports_section_edit?
      @section = params[:section].to_i
      @section_hash = params[:section_hash]
      @content.text = Redmine::WikiFormatting.formatter.new(@content.text).update_section(params[:section].to_i, @text, @section_hash)
    else
      @content.version = content_params[:version] if content_params[:version]
      @content.text = @text
    end
    @content.author = User.current
    #plugin modification MODIFICATION
    @content.mail_checker_wiki = params[:email_checker_wiki]
    #END
  if @page.save_with_content
      attachments = Attachment.attach_files(@page, params[:attachments])
      render_attachment_warning_if_needed(@page)
      call_hook(:controller_wiki_edit_after_save, { :params => params, :page => @page})

      respond_to do |format|
        format.html { redirect_to project_wiki_page_path(@project, @page.title) }
        format.api {
          if was_new_page
            render :action => 'show', :status => :created, :location => project_wiki_page_path(@project, @page.title)
          else
            render_api_ok
          end
        }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api { render_validation_errors(@content) }
      end
    end

  rescue ActiveRecord::StaleObjectError, Redmine::WikiFormatting::StaleSectionError
    # Optimistic locking exception
    respond_to do |format|
      format.html {
        flash.now[:error] = l(:notice_locking_conflict)
        render :action => 'edit'
      }
      format.api { render_api_head :conflict }
    end
  rescue ActiveRecord::RecordNotSaved
    respond_to do |format|
      format.html { render :action => 'edit' }
      format.api { render_validation_errors(@content) }
    end
  end
end

Rails.configuration.to_prepare do
  WikiController.send(:include, WikiSendParamPatch)
end