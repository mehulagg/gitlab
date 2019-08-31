# frozen_string_literal: true

class OpenProjectHttp
  include ProjectServicesLoggable

  JSON_METHODS = [Net::HTTP::Patch, Net::HTTP::Post, Net::HTTP::Put].freeze

  def initialize(api_url, token)
    @api_url = api_url
    @token = token
  end

  def open_project_http(method, path, api, body, op_id)
    url = "#{@api_url}/#{path}/#{op_id}/#{api}"
    basic_auth = "apikey:#{@token}"
    basic_auth_base64 = Base64.encode64(basic_auth).delete("\n")
    options = { headers: { Authorization: "Basic #{basic_auth_base64}" } }

    if JSON_METHODS.include?(method)
      options[:body] = body
      options[:headers]['Content-Type'] = 'application/json'
    end

    Gitlab::HTTP.perform_request(method, url, options)
  end

  # Open Project Work Package API HTTP Client
  # @param op_id is the unique Open Project Work Package(issue) ID
  # method: SupportedHTTPMethods = [ Net::HTTP::Get, Net::HTTP::Post, Net::HTTP::Patch]
  # see https://github.com/jnunemaker/httparty/blob/master/lib/httparty/request.rb
  def open_project_wp_http(method, api, body, op_id)
    open_project_http(method, 'work_packages', api, body, op_id)
  end

  def open_project_config_http(method, api, body)
    open_project_http(method, 'configuration', api, body, '')
  end

  def send_message(issue, message, remote_link_props)
    work_package_comment = {
        comment: {
            raw: message
        }
    }

    response = open_project_wp_http(Net::HTTP::Post, 'activities?notify=false', JSON[work_package_comment], issue)
    # log_debug("Successfully posted " + response.to_s)
    "SUCCESS: Successfully send message"
  end

  def close_issue(op_id, closed_status_id)
    # before change the status should get lockVersion by using GET the work package
    response = open_project_wp_http(Net::HTTP::Get, '', '', op_id)
    obj = JSON.parse(response.read_body)
    lock_version = obj['lockVersion']

    # change to Work Package to close status
    close_issue_body = {
        lockVersion: lock_version,
        _links: {
            status: {
                href: "/api/v3/statuses/#{closed_status_id}"
            }
        }
    }
    response = open_project_wp_http(Net::HTTP::Patch, '?notify=false', JSON[close_issue_body], op_id)

    # log_debug('Successfully posted ', response.to_s)
    'SUCCESS: Successfully close issue'
  end
end
