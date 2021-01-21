# frozen_string_literal: true

module Emails
  module Requirements
    def import_requirements_csv_email(user_id, project_id, results)
      @user = User.find(user_id)
      @project = Project.find(project_id)
      @results = results

      requirement_email_with_layout(@user, @project.group, _('Imported requirements'))
    end

    def requirements_csv_email(user, project, csv_data, export_status)
      @project = project
      @count, @written_count, @truncated = export_status.fetch_values(:rows_expected, :rows_written, :truncated)
      @size_limit = ActiveSupport::NumberHelper.number_to_human_size(Issuable::ExportCsv::BaseService::TARGET_FILESIZE)

      filename = "#{project.full_path.parameterize}_requirements_#{Date.current.iso8601}.csv"
      attachments[filename] = { content: csv_data, mime_type: 'text/csv' }

      requirement_email_with_layout(user, @project.group, _('Exported requirements'))
    end

    def requirement_email_with_layout(user, group, subj)
      mail(to: user.notification_email_for(group), subject: subject(subj)) do |format|
        format.html { render layout: 'mailer' }
        format.text { render layout: 'mailer' }
      end
    end
  end
end
