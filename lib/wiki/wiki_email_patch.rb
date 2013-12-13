Rails.configuration.to_prepare do
  require_dependency 'wiki_content'
  class WikiContent
    attr_accessor :mail_checker_wiki
  end
end