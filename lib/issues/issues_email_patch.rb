Rails.configuration.to_prepare do
  require_dependency 'issue'
  class Issue
    attr_accessor :mail_checker_issue
  end
end