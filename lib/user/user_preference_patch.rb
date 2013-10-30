require_dependency 'user_preference'

module UserPreferenceCheckMailPatch
    def self.included(base)
      base.send(:include, InstanceMethods)  
    end
end

module InstanceMethods

  def always_check_email; (self[:always_check_email] == true || self[:always_check_email] == '1'); end
  def always_check_email=(value); self[:always_check_email]=value; end
    
end

Rails.configuration.to_prepare do
  UserPreference.send(:include, UserPreferenceCheckMailPatch)
end