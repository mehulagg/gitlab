# frozen_string_literal: true

class Import::BitbucketController < Import::BaseController
  include ActionView::Helpers::SanitizeHelper

  before_action :verify_bitbucket_import_enabled
  before_action :bitbucket_auth, except: :callback

  rescue_from OAuth2::Error, with: :bitbucket_unauthorized
  rescue_from Bitbucket::Error::Unauthorized, with: :bitbucket_unauthorized

  def callback
    response = client.auth_code.get_token(params[:code], redirect_uri: users_import_bitbucket_callback_url)

    session[:bitbucket_token]         = response.token
    session[:bitbucket_expires_at]    = response.expires_at
    session[:bitbucket_expires_in]    = response.expires_in
    session[:bitbucket_refresh_token] = response.refresh_token

    redirect_to status_import_bitbucket_url
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def status
    bitbucket_client = Bitbucket::Client.new(credentials)
    repos = bitbucket_client.repos(filter: sanitized_filter_param)

    @repos, @incompatible_repos = repos.partition { |repo| repo.valid? }

    @already_added_projects = find_already_added_projects('bitbucket')
    already_added_projects_names = @already_added_projects.pluck(:import_source)

    @repos.to_a.reject! { |repo| already_added_projects_names.include?(repo.full_name) }
    respond_to do |format|
      format.json do
        render json: { imported_projects: serialized_imported_projects(@already_added_projects),
                        provider_repos: serialized_provider_repos,
                        namespaces: serialized_namespaces }
      end
      format.html
    end
  end

  def serialized_provider_repos
    repos = @repos.map {|repo| { id: repo.full_name, full_name: repo.full_name, name: repo.name, owner: { login: repo.owner }, provider_link: repo.clone_url } }
    # repos = @repos.map {|repo| { full_name => 'full_name', sanitized_name => 'name', owner_name => 'lol', provider_link => 'lol', id => 'f' } }
    ProviderRepoSerializer.new(current_user: current_user).represent(repos, provider: provider, provider_url: provider_url)
  end

  def provider_url
    'https://bitbucket.org'
  end

  def serialized_namespaces
    NamespaceSerializer.new.represent(namespaces)
  end

  def serialized_imported_projects(projects = already_added_projects)
    ProjectSerializer.new.represent(projects, serializer: :import, provider_url: provider_url)
  end

  def namespaces
    current_user.manageable_groups_with_routes
  end

  # rubocop: enable CodeReuse/ActiveRecord
  def realtime_changes
    render json: find_jobs('bitbucket')
  end

  def create
    bitbucket_client = Bitbucket::Client.new(credentials)

    repo_id = params[:repo_id].to_s
    name = repo_id.gsub('___', '/')
    repo = bitbucket_client.repo(name)
    project_name = params[:new_name].presence || repo.name

    repo_owner = repo.owner
    repo_owner = current_user.username if repo_owner == bitbucket_client.user.username
    namespace_path = params[:new_namespace].presence || repo_owner
    target_namespace = find_or_create_namespace(namespace_path, current_user)

    if current_user.can?(:create_projects, target_namespace)
      # The token in a session can be expired, we need to get most recent one because
      # Bitbucket::Connection class refreshes it.
      session[:bitbucket_token] = bitbucket_client.connection.token

      project = Gitlab::BitbucketImport::ProjectCreator.new(repo, project_name, target_namespace, current_user, credentials).execute

      if project.persisted?
        render json: ProjectSerializer.new.represent(project)
      else
        render json: { errors: project_save_error(project) }, status: :unprocessable_entity
      end
    else
      render json: { errors: _('This namespace has already been taken! Please choose another one.') }, status: :unprocessable_entity
    end
  end

  private

  def client
    @client ||= OAuth2::Client.new(provider.app_id, provider.app_secret, options)
  end

  def provider
    Gitlab::Auth::OAuth::Provider.config_for('bitbucket')
  end

  def options
    OmniAuth::Strategies::Bitbucket.default_options[:client_options].deep_symbolize_keys
  end

  def verify_bitbucket_import_enabled
    render_404 unless bitbucket_import_enabled?
  end

  def bitbucket_auth
    go_to_bitbucket_for_permissions if session[:bitbucket_token].blank?
  end

  def go_to_bitbucket_for_permissions
    redirect_to client.auth_code.authorize_url(redirect_uri: users_import_bitbucket_callback_url)
  end

  def bitbucket_unauthorized
    go_to_bitbucket_for_permissions
  end

  def credentials
    {
      token: session[:bitbucket_token],
      expires_at: session[:bitbucket_expires_at],
      expires_in: session[:bitbucket_expires_in],
      refresh_token: session[:bitbucket_refresh_token]
    }
  end

  def sanitized_filter_param
    @filter ||= sanitize(params[:filter])
  end
end
