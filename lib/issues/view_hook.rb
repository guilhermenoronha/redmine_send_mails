module Redmine_send_mails
  class Hooks < Redmine::Hook::ViewListener
    #EDIT
    render_on :view_issues_edit_notes_top,
              :partial => 'issues/edit_hook'
    
    #NEW
    render_on :view_issues_form_details_bottom,
              :partial => 'issues/new_hook'    
    #BULK_EDIT
    render_on :view_issues_bulk_edit_details_bottom,
              :partial => 'issues/bulk_edit_hook'
  end
end