# == Issuable concern
#
# Contains common functionality shared between Issues and MergeRequests
#
# Used by Issue, MergeRequest
#
module Issuable
  extend ActiveSupport::Concern
  include CacheMarkdownField
  include Participable
  include Mentionable
  include Subscribable
  include StripAttribute
  include Awardable
  include Taskable
  include TimeTrackable

  # This object is used to gather issuable meta data for displaying
  # upvotes, downvotes, notes and closing merge requests count for issues and merge requests
  # lists avoiding n+1 queries and improving performance.
  IssuableMeta = Struct.new(:upvotes, :downvotes, :notes_count, :merge_requests_count)

  included do
    cache_markdown_field :title, pipeline: :single_line
    cache_markdown_field :description

    belongs_to :author, class_name: "User"
    has_and_belongs_to_many :assignees, class_name: "User", join_table: :issuable_assignees
    belongs_to :updated_by, class_name: "User"
    belongs_to :milestone
    has_many :notes, as: :noteable, inverse_of: :noteable, dependent: :destroy do
      def authors_loaded?
        # We check first if we're loaded to not load unnecessarily.
        loaded? && to_a.all? { |note| note.association(:author).loaded? }
      end

      def award_emojis_loaded?
        # We check first if we're loaded to not load unnecessarily.
        loaded? && to_a.all? { |note| note.association(:award_emoji).loaded? }
      end
    end

    has_many :label_links, as: :target, dependent: :destroy
    has_many :labels, through: :label_links
    has_many :todos, as: :target, dependent: :destroy

    has_one :metrics

    delegate :name,
             :email,
             to: :author,
             prefix: true

    delegate :name,
             :email,
             to: :assignee,
             allow_nil: true,
             prefix: true

    validates :author, presence: true
    validates :title, presence: true, length: { maximum: 255 }

    scope :authored, ->(user) { where(author_id: user) }
    scope :assigned_to, ->(u) { where(assignee_id: u.id)}
    scope :recent, -> { reorder(id: :desc) }
    scope :order_position_asc, -> { reorder(position: :asc) }
    scope :assigned, -> { where("assignee_id IS NOT NULL") }
    scope :unassigned, -> { where("assignee_id IS NULL") }
    scope :of_projects, ->(ids) { where(project_id: ids) }
    scope :of_milestones, ->(ids) { where(milestone_id: ids) }
    scope :with_milestone, ->(title) { left_joins_milestones.where(milestones: { title: title }) }
    scope :opened, -> { with_state(:opened, :reopened) }
    scope :only_opened, -> { with_state(:opened) }
    scope :only_reopened, -> { with_state(:reopened) }
    scope :closed, -> { with_state(:closed) }
    scope :order_milestone_due_desc, -> { outer_join_milestone.reorder('milestones.due_date IS NULL ASC, milestones.due_date DESC, milestones.id DESC') }
    scope :order_milestone_due_asc, -> { outer_join_milestone.reorder('milestones.due_date IS NULL ASC, milestones.due_date ASC, milestones.id ASC') }
    scope :without_label, -> { joins("LEFT OUTER JOIN label_links ON label_links.target_type = '#{name}' AND label_links.target_id = #{table_name}.id").where(label_links: { id: nil }) }

    scope :left_joins_milestones,    -> { joins("LEFT OUTER JOIN milestones ON #{table_name}.milestone_id = milestones.id") }
    scope :order_milestone_due_desc, -> { left_joins_milestones.reorder('milestones.due_date IS NULL, milestones.id IS NULL, milestones.due_date DESC') }
    scope :order_milestone_due_asc,  -> { left_joins_milestones.reorder('milestones.due_date IS NULL, milestones.id IS NULL, milestones.due_date ASC') }

    scope :without_label, -> { joins("LEFT OUTER JOIN label_links ON label_links.target_type = '#{name}' AND label_links.target_id = #{table_name}.id").where(label_links: { id: nil }) }
    scope :join_project, -> { joins(:project) }
    scope :inc_notes_with_associations, -> { includes(notes: [:project, :author, :award_emoji]) }
    scope :references_project, -> { references(:project) }
    scope :non_archived, -> { join_project.where(projects: { archived: false }) }

    attr_mentionable :title, pipeline: :single_line
    attr_mentionable :description

    participant :author
    participant :assignee
    participant :notes_with_associations

    strip_attributes :title

    acts_as_paranoid

    after_save :update_assignee_cache_counts, if: :assignee_id_changed?
    after_save :record_metrics

    def update_assignee_cache_counts
      # make sure we flush the cache for both the old *and* new assignees(if they exist)
      previous_assignee = User.find_by_id(assignee_id_was) if assignee_id_was
      previous_assignee&.update_cache_counts
      assignee&.update_cache_counts
    end

    # We want to use optimistic lock for cases when only title or description are involved
    # http://api.rubyonrails.org/classes/ActiveRecord/Locking/Optimistic.html
    def locking_enabled?
      title_changed? || description_changed?
    end
  end

  module ClassMethods
    # Searches for records with a matching title.
    #
    # This method uses ILIKE on PostgreSQL and LIKE on MySQL.
    #
    # query - The search query as a String
    #
    # Returns an ActiveRecord::Relation.
    def search(query)
      where(arel_table[:title].matches("%#{query}%"))
    end

    # Searches for records with a matching title or description.
    #
    # This method uses ILIKE on PostgreSQL and LIKE on MySQL.
    #
    # query - The search query as a String
    #
    # Returns an ActiveRecord::Relation.
    def full_search(query)
      t = arel_table
      pattern = "%#{query}%"

      where(t[:title].matches(pattern).or(t[:description].matches(pattern)))
    end

    def sort(method, excluded_labels: [])
      sorted = case method.to_s
               when 'milestone_due_asc' then order_milestone_due_asc
               when 'milestone_due_desc' then order_milestone_due_desc
               when 'downvotes_desc' then order_downvotes_desc
               when 'upvotes_desc' then order_upvotes_desc
               when 'label_priority' then order_labels_priority(excluded_labels: excluded_labels)
               when 'priority' then order_due_date_and_labels_priority(excluded_labels: excluded_labels)
               when 'position_asc' then  order_position_asc
               else
                 order_by(method)
               end

      # Break ties with the ID column for pagination
      sorted.order(id: :desc)
    end

    def order_due_date_and_labels_priority(excluded_labels: [])
      # The order_ methods also modify the query in other ways:
      #
      # - For milestones, we add a JOIN.
      # - For label priority, we change the SELECT, and add a GROUP BY.#
      #
      # After doing those, we need to reorder to the order we want. The existing
      # ORDER BYs won't work because:
      #
      # 1. We need milestone due date first.
      # 2. We can't ORDER BY a column that isn't in the GROUP BY and doesn't
      #    have an aggregate function applied, so we do a useless MIN() instead.
      #
      milestones_due_date = 'MIN(milestones.due_date)'

      order_milestone_due_asc.
        order_labels_priority(excluded_labels: excluded_labels, extra_select_columns: [milestones_due_date]).
        reorder(Gitlab::Database.nulls_last_order(milestones_due_date, 'ASC'),
                Gitlab::Database.nulls_last_order('highest_priority', 'ASC'))
    end

    def order_labels_priority(excluded_labels: [], extra_select_columns: [])
      params = {
        target_type: name,
        target_column: "#{table_name}.id",
        project_column: "#{table_name}.#{project_foreign_key}",
        excluded_labels: excluded_labels
      }

      highest_priority = highest_label_priority(params).to_sql

      select_columns = [
        "#{table_name}.*",
        "(#{highest_priority}) AS highest_priority"
      ] + extra_select_columns

      select(select_columns.join(', ')).
        group(arel_table[:id]).
        reorder(Gitlab::Database.nulls_last_order('highest_priority', 'ASC'))
    end

    def with_label(title, sort = nil)
      if title.is_a?(Array) && title.size > 1
        joins(:labels).where(labels: { title: title }).group(*grouping_columns(sort)).having("COUNT(DISTINCT labels.title) = #{title.size}")
      else
        joins(:labels).where(labels: { title: title })
      end
    end

    def labels_hash
      issue_labels = Hash.new { |h, k| h[k] = [] }
      eager_load(:labels).pluck(:id, 'labels.title').each do |issue_id, label|
        issue_labels[issue_id] << label
      end
      issue_labels
    end

    # Includes table keys in group by clause when sorting
    # preventing errors in postgres
    #
    # Returns an array of arel columns
    def grouping_columns(sort)
      grouping_columns = [arel_table[:id]]

      if %w(milestone_due_desc milestone_due_asc).include?(sort)
        milestone_table = Milestone.arel_table
        grouping_columns << milestone_table[:id]
        grouping_columns << milestone_table[:due_date]
      end

      grouping_columns
    end

    def to_ability_name
      model_name.singular
    end
  end

  def today?
    Date.today == created_at.to_date
  end

  def new?
    today? && created_at == updated_at
  end

  def is_being_reassigned?
    assignee_id_changed?
  end

  def open?
    opened? || reopened?
  end

  def user_notes_count
    if notes.loaded?
      # Use the in-memory association to select and count to avoid hitting the db
      notes.to_a.count { |note| !note.system? }
    else
      # do the count query
      notes.user.count
    end
  end

  def subscribed_without_subscriptions?(user, project)
    participants(user).include?(user)
  end

  def to_hook_data(user)
    hook_data = {
      object_kind: self.class.name.underscore,
      user: user.hook_attrs,
      project: project.hook_attrs,
      object_attributes: hook_attrs,
      # DEPRECATED
      repository: project.hook_attrs.slice(:name, :url, :description, :homepage)
    }
    hook_data[:assignee] = assignee.hook_attrs if assignee

    hook_data
  end

  def labels_array
    labels.to_a
  end

  def label_names
    labels.order('title ASC').pluck(:title)
  end

  # Convert this Issuable class name to a format usable by Ability definitions
  #
  # Examples:
  #
  #   issuable.class           # => MergeRequest
  #   issuable.to_ability_name # => "merge_request"
  def to_ability_name
    self.class.to_ability_name
  end

  # Convert this Issuable class name to a format usable by notifications.
  #
  # Examples:
  #
  #   issuable.class           # => MergeRequest
  #   issuable.human_class_name # => "merge request"

  def human_class_name
    @human_class_name ||= self.class.name.titleize.downcase
  end

  # Returns a Hash of attributes to be used for Twitter card metadata
  def card_attributes
    {
      'Author'   => author.try(:name),
      'Assignee' => assignee.try(:name)
    }
  end

  def notes_with_associations
    # If A has_many Bs, and B has_many Cs, and you do
    # `A.includes(b: :c).each { |a| a.b.includes(:c) }`, sadly ActiveRecord
    # will do the inclusion again. So, we check if all notes in the relation
    # already have their authors loaded (possibly because the scope
    # `inc_notes_with_associations` was used) and skip the inclusion if that's
    # the case.
    includes = []
    includes << :author unless notes.authors_loaded?
    includes << :award_emoji unless notes.award_emojis_loaded?
    if includes.any?
      notes.includes(includes)
    else
      notes
    end
  end

  def updated_tasks
    Taskable.get_updated_tasks(old_content: previous_changes['description'].first,
                               new_content: description)
  end

  ##
  # Method that checks if issuable can be moved to another project.
  #
  # Should be overridden if issuable can be moved.
  #
  def can_move?(*)
    false
  end

  def assignee_or_author?(user)
    # We're comparing IDs here so we don't need to load any associations.
    author_id == user.id || assignee_id == user.id
  end

  def record_metrics
    metrics = self.metrics || create_metrics
    metrics.record!
  end
end
