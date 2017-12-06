class GeoNode < ActiveRecord::Base
  include IgnorableColumn
  include Presentable

  ignore_column :clone_protocol
  ignore_column :geo_node_key_id

  belongs_to :oauth_application, class_name: 'Doorkeeper::Application', dependent: :destroy # rubocop: disable Cop/ActiveRecordDependent

  has_many :geo_node_namespace_links
  has_many :namespaces, through: :geo_node_namespace_links
  has_one :status, class_name: 'GeoNodeStatus'

  default_values url: ->(record) { record.class.current_node_url },
                 primary: false

  validates :url, presence: true, uniqueness: { case_sensitive: false }
  validate :check_url_is_valid

  validates :primary, uniqueness: { message: 'node already exists' }, if: :primary

  validates :access_key, presence: true
  validates :encrypted_secret_access_key, presence: true

  validate :check_not_adding_primary_as_secondary, if: :secondary?

  after_save :expire_cache!
  after_destroy :expire_cache!
  before_validation :update_dependents_attributes

  before_validation :ensure_access_keys!

  scope :with_url_prefix, ->(prefix) { where('url LIKE ?', "#{prefix}%") }

  attr_encrypted :secret_access_key,
                 key: Gitlab::Application.secrets.db_key_base,
                 algorithm: 'aes-256-gcm',
                 mode: :per_attribute_iv,
                 encode: true

  class << self
    def current_node_url
      RequestStore.fetch('geo_node:current_node_url') do
        cfg = Gitlab.config.gitlab

        uri = URI.parse("#{cfg.protocol}://#{cfg.host}:#{cfg.port}#{cfg.relative_url_root}")
        uri.path += '/' unless uri.path.end_with?('/')

        uri.to_s
      end
    end

    def current_node
      return unless column_names.include?('url')

      GeoNode.find_by(url: current_node_url)
    end
  end

  def current?
    self.class.current_node_url == url
  end

  def secondary?
    !primary
  end

  def uses_ssh_key?
    secondary? && clone_protocol == 'ssh'
  end

  def url
    value = read_attribute(:url)
    value += '/' if value.present? && !value.end_with?('/')

    value
  end

  def url=(value)
    value += '/'  if value.present? && !value.end_with?('/')

    write_attribute(:url, value)

    @uri = nil
  end

  def uri
    @uri ||= URI.parse(url) if url.present?
  end

  def geo_transfers_url(file_type, file_id)
    geo_api_url("transfers/#{file_type}/#{file_id}")
  end

  def status_url
    geo_api_url('status')
  end

  def oauth_callback_url
    Gitlab::Routing.url_helpers.oauth_geo_callback_url(url_helper_args)
  end

  def oauth_logout_url(state)
    Gitlab::Routing.url_helpers.oauth_geo_logout_url(url_helper_args.merge(state: state))
  end

  def missing_oauth_application?
    self.primary? ? false : !oauth_application.present?
  end

  def update_clone_url!
    update_clone_url

    # Update with update_column to prevent calling callbacks as this method will
    # be called in an initializer and we don't want other callbacks
    # to mess with uninitialized dependencies.
    if clone_url_prefix_changed?
      Rails.logger.info "Geo: modified clone_url_prefix to #{clone_url_prefix}"
      update_column(:clone_url_prefix, clone_url_prefix)
    end
  end

  def projects_include?(project_id)
    return true if restricted_project_ids.nil?

    restricted_project_ids.include?(project_id)
  end

  def restricted_project_ids
    return unless namespaces.presence

    relations = namespaces.map { |namespace| namespace.all_projects.select(:id) }

    Project.unscoped
       .from("(#{Gitlab::SQL::Union.new(relations).to_sql}) #{Project.table_name}")
       .pluck(:id)
  end

  def lfs_objects
    relation =
      if restricted_project_ids
        LfsObject.joins(:projects).where(projects: { id: restricted_project_ids })
      else
        LfsObject.all
      end

    relation.with_files_stored_locally
  end

  def projects
    if restricted_project_ids
      Project.where(id: restricted_project_ids)
    else
      Project.all
    end
  end

  def project_registries
    if restricted_project_ids
      Geo::ProjectRegistry.where(project_id: restricted_project_ids)
    else
      Geo::ProjectRegistry.all
    end
  end

  def filtered_project_registries(type = nil)
    case type
    when 'repository'
      project_registries.failed_repos
    when 'wiki'
      project_registries.failed_wikis
    else
      project_registries.failed
    end
  end

  def uploads
    if restricted_project_ids
      uploads_table   = Upload.arel_table
      group_uploads   = uploads_table[:model_type].eq('Namespace').and(uploads_table[:model_id].in(Gitlab::Geo.current_node.namespace_ids))
      project_uploads = uploads_table[:model_type].eq('Project').and(uploads_table[:model_id].in(restricted_project_ids))
      other_uploads   = uploads_table[:model_type].not_in(%w[Namespace Project])

      Upload.where(group_uploads.or(project_uploads).or(other_uploads))
    else
      Upload.all
    end
  end

  def lfs_objects_synced_count
    return unless secondary?

    relation = Geo::FileRegistry.lfs_objects.synced

    if restricted_project_ids
      relation = relation.where(file_id: lfs_objects.pluck(:id))
    end

    relation.count
  end

  def lfs_objects_failed_count
    return unless secondary?

    Geo::FileRegistry.lfs_objects.failed.count
  end

  def attachments_synced_count
    return unless secondary?

    upload_ids = uploads.pluck(:id)
    synced_ids = Geo::FileRegistry.attachments.synced.pluck(:file_id)

    (synced_ids & upload_ids).length
  end

  def attachments_failed_count
    return unless secondary?

    Geo::FileRegistry.attachments.failed.count
  end

  def find_or_build_status
    status || build_status
  end

  private

  def geo_api_url(suffix)
    URI.join(uri, "#{uri.path}", "api/#{API::API.version}/geo/#{suffix}").to_s
  end

  def ensure_access_keys!
    return if self.access_key.present? && self.encrypted_secret_access_key.present?

    keys = Gitlab::Geo.generate_access_keys

    self.access_key = keys[:access_key]
    self.secret_access_key = keys[:secret_access_key]
  end

  def url_helper_args
    { protocol: uri.scheme, host: uri.host, port: uri.port, script_name: uri.path }
  end

  def update_dependents_attributes
    if self.primary?
      self.oauth_application = nil
      update_clone_url
    else
      update_oauth_application!
    end
  end

  # Prevent locking yourself out
  def check_not_adding_primary_as_secondary
    if url == self.class.current_node_url
      errors.add(:base, 'Current node must be the primary node or you will be locking yourself out')
    end
  end

  def check_url_is_valid
    if uri.present? && !%w[http https].include?(uri.scheme)
      errors.add(:url, 'scheme must be http or https')
    end
  rescue URI::InvalidURIError
    errors.add(:url,  'is invalid')
  end

  def update_clone_url
    self.clone_url_prefix = Gitlab.config.gitlab_shell.ssh_path_prefix
  end

  def update_oauth_application!
    self.build_oauth_application if oauth_application.nil?
    self.oauth_application.name = "Geo node: #{self.url}"
    self.oauth_application.redirect_uri = oauth_callback_url
  end

  def expire_cache!
    Gitlab::Geo.expire_cache!
  end
end
