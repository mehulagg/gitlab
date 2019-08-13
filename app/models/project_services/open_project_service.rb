# frozen_string_literal: true

class OpenProjectService < IssueTrackerService
  validates :url, public_url: true, presence: true, if: :activated?
  validates :api_url, public_url: true, allow_blank: true, if: :activated?
  validates :token, presence: true, if: :activated?
  validates :project_identifier_code, presence: true, if: :activated?

  data_field :url, :api_url, :token, :closed_status_id, :project_identifier_code

  def data_fields
    open_project_tracker_data || self.build_open_project_tracker_data
  end

  def self.to_param
    'open_project'
  end

  override :issue_tracker_name
  def self.issue_tracker_name
    "Open Project"
  end

  override :initialize_properties
  def initialize_properties
    super do
      self.properties = {
          title: issues_tracker['title'],
          url: issues_tracker['url'],
          api_url: issues_tracker['api_url'],
          token: issues_tracker['token']
      }
    end
  end

  override :help
  def help
    "You need to configure OpenProject before enabling this service. For more details
    read the
    [OpenProject service documentation](#{help_page_url('user/project/integrations/open_project')})."
  end

  override :description
  def description
    self.properties&.dig('description') || s_('OpenProjectService|' + super)
  end

  override :test
  def test(_)
    response = client.open_project_config_http(Net::HTTP::Get, "", "")
    success = false

    if response.code == 200
      success = true
      result = response.code
    else
      result = "Error code: #{response.code}. Message: #{JSON.parse(response.parsed_response)['message']}"
    end

    { success: success, result: result }
  end

  # OpenProject does not need test data.
  # <b>Develop Note</b>: this method make the properties ready when do `test`
  override :test_data
  def test_data(user = nil, project = nil)
    nil
  end

  # Get the unique open project work package id from the issue id, e.g. PROJECT-34: unique id is 34.
  def get_open_project_id_from_issue_id(op_issue_id)
    op_issue_array = op_issue_id.to_s.split("-")
    op_issue_array[1]
  end

  override :tracker_issue_by_gitlab_id
  def tracker_issue_by_gitlab_id(mentioned_id)
    get_open_project_id_from_issue_id(mentioned_id)
  end

  def client
    @client ||= OpenProjectHttp.new(self.api_url, self.token)
  end

  # In order to close the Open Project Work Package the ID of Closed Status is needed. The status of Work Package
  #   will be changed to status of Closed ID
  override :close_issue
  def close_issue(entity, external_issue)
    op_id = get_open_project_id_from_issue_id(external_issue.iid)
    commit_id = commit_id(entity)
    commit_url = build_entity_url(:commit, commit_id)

    add_issue_solved_comment(op_id, commit_id, commit_url)
    client.close_issue(op_id, self.closed_status_id)
  end

  override :send_message
  def send_message(issue, message, remote_link_props)
    client.send_message(issue, message, remote_link_props)
  end

  def project_identifier_code
    self.properties&.dig('project_identifier_code') || project&.path
  end

  # this is used to get the service name
  override :to_param
  def self.to_param
    'open_project'
  end

  # we need to find the project code and id in the iid.  PROJECT-1
  override :issue_url
  def issue_url(iid)
    project_with_id = iid.to_s.split("-")
    issue_url_render(self.issues_url, project_with_id)
  end

  # basic OpenProject project id URL build
  def issue_url_render(issues_url_template, project_with_id)
    issues_url_template.gsub(':project_id', project_with_id[0].downcase).gsub(':id', project_with_id[1])
  end

  def base_url
    self.properties['url'].to_s.gsub(/\/$/, "")
  end

  def issues_url
    return self.properties['issues_url'] if self.properties&.dig('issues_url')&.present?

    if self.base_url.present?
      "#{base_url}/projects/:project_id/work_packages/:id"
    end
  end

  def project_url
    return self.properties['project_url'] if self.properties&.dig('project_url')&.present?

    if self.base_url.present?
      return "#{base_url}/projects/#{project_identifier_code}" if self.properties&.dig('project_identifier_code')&.present?

      "#{base_url}/projects/#{project&.path}/work_packages" if project&.path&.present?
    end
  end

  override :api_url
  def api_url
    return self.properties['api_url'] if self.properties&.dig('api_url')&.present?

    if self.base_url.present?
      "#{base_url}/api/v3"
    end
  end

  def closed_status_id
    self.properties&.dig('closed_status_id') || DEFAULT_CLOSED_STATUS_ID
  end

  override :fields
  def fields
    [
        { type: 'text', name: 'title', title: s_('OpenProjectService|Title'), placeholder: s_("OpenProjectService|" + title) },
        { type: 'text', name: 'description', title: s_('OpenProjectService|Description'), placeholder: s_("OpenProjectService|" + description) },
        # support two parameters in the url: project_id (unique project identifier) and id (unique issue id)
        { type: 'text', name: 'url', title: s_('OpenProjectService|Web URL'), placeholder: s_('OpenProjectService|https://gitlab-integration.openproject.com'), required: true },
        { type: 'text', name: 'project_identifier_code', title: s_('OpenProjectService|Project Identifier'), placeholder: s_('OpenProjectService|demo') },
        { type: 'text', name: 'project_url', title: s_('OpenProjectService|Project URL'), placeholder: s_('OpenProjectService|https://gitlab-integration.openproject.com/projects/xin') },
        { type: 'text', name: 'issues_url', title: s_('OpenProjectService|Issue URL'), placeholder: s_('OpenProjectService|https://gitlab-integration.openproject.com/projects/:project_id/work_packages/:id') },
        { type: 'text', name: 'api_url', title: s_('OpenProjectService|Open Project API URL'), placeholder: s_('OpenProjectService|https://gitlab-integration.openproject.com/api/v3/') },
        { type: 'password', name: 'token', title: s_('OpenProjectService|API token'), placeholder: s_('OpenProjectService|the API token for access the OpenProject API and the corresponding user will be set as the comment owner'), required: true },
        { type: 'text', name: 'closed_status_id', title: s_('OpenProjectService|Closed Status ID'), placeholder: s_('OpenProjectService|13 which is default for Open Project'), required: true }
    ]
  end
end
