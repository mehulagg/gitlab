# frozen_string_literal: true

module Emails
  module Requirements
    def import_requirements_csv_email(user_id, project_id, results)
      @user = User.find(user_id)
      @project = Project.find(project_id)
      @results = results

      mail(to: @user.notification_email_for(@project.group), subject: subject('Imported requirements')) do |format|
        format.html { render layout: 'mailer' }
        format.text { render layout: 'mailer' }
      end
    end
  end
end
