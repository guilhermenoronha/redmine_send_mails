require_dependency 'user_preference'

module UserPreferenceCheckMailPatch
    def self.included(base)
      base.send(:include, InstanceMethods)  
    end
end

module InstanceMethods

  def always_check_email; (self[:always_check_email] == true || self[:always_check_email] == '1'); end
  def always_check_email=(value); self[:always_check_email]=value; end
  

  #BUG FIX FOR VERSIONS BEFORE 2.3.2 
  if Redmine::VERSION.to_a[0..2].join.to_i < 232
    def no_self_notified; (self[:no_self_notified] == true || self[:no_self_notified] == '1'); end
    def no_self_notified=(value); self[:no_self_notified]=value; end
  end
    
end

Rails.configuration.to_prepare do
  UserPreference.send(:include, UserPreferenceCheckMailPatch)
end