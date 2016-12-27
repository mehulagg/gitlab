class BugzillaService < IssueTrackerService
  validates :project_url, :issues_url, :new_issue_url, presence: true, url: true, if: :activated?

  prop_accessor :title, :description, :project_url, :issues_url, :new_issue_url

  def title
    if self.properties && self.properties['title'].present?
      self.properties['title']
    else
      'Bugzilla'
    end
  end

  def description
    if self.properties && self.properties['description'].present?
      self.properties['description']
    else
      'Bugzilla issue tracker'
    end
  end

  def self.to_param
    'bugzilla'
  end

  def self.supported_events
    %w()
  end

  def self.event_names
    self.supported_events.map { |event| "#{event}_events" }
  end
end
