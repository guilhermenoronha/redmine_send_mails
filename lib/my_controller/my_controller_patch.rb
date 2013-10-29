module MyControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        alias_method_chain :account, :always_check_email
      end
    end
end

module InstanceMethods
    def account_with_always_check_email
      @user = User.current
      @pref = @user.pref
      if request.post?
        @user.safe_attributes = params[:user]
        @user.pref.attributes = params[:pref]
        @user.pref[:no_self_notified] = (params[:no_self_notified] == '1')
        
        #Redmine Send Email Modification
        @user.pref[:always_check_email] = (params[:always_check_email] == '1')
        
        if @user.save
          @user.pref.save
          @user.notified_project_ids = (@user.mail_notification == 'selected' ? params[:notified_project_ids] : [])
          set_language_if_valid @user.language
          flash[:notice] = l(:notice_account_updated)
          redirect_to :action => 'account'
          return
        end
    end
  end
end

Rails.configuration.to_prepare do
  MyController.send(:include, MyControllerPatch)
end