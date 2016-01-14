Dir["#{Rails.root}/lib/api/*.rb"].each {|file| require file}

module API
  class API < Grape::API
    include APIGuard
    version 'v3', using: :path

    rescue_from ActiveRecord::RecordNotFound do
      rack_response({ 'message' => '404 Not found' }.to_json, 404)
    end

    rescue_from :all do |exception|
      # lifted from https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L60
      # why is this not wrapped in something reusable?
      trace = exception.backtrace

      message = "\n#{exception.class} (#{exception.message}):\n"
      message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
      message << "  " << trace.join("\n  ")

      API.logger.add Logger::FATAL, message
      rack_response({ 'message' => '500 Internal Server Error' }.to_json, 500)
    end

    format :json
    content_type :txt, "text/plain"

    helpers Helpers

    mount Groups
    mount GroupMembers
    mount Users
    mount Projects
    mount Repositories
    mount Issues
    mount Milestones
    mount Session
    mount MergeRequests
    mount Notes
    mount Internal
    mount SystemHooks
    mount ProjectSnippets
    mount ProjectMembers
    mount DeployKeys
    mount ProjectHooks
    mount ProjectGitHook
    mount Ldap
    mount LdapGroupLinks
    mount Services
    mount Files
    mount Commits
    mount CommitStatus
    mount Namespaces
    mount Branches
    mount Labels
    mount Settings
    mount Keys
    mount Tags
    mount LicenseInfo
    mount Triggers
    mount Builds
    mount Variables
  end
end
