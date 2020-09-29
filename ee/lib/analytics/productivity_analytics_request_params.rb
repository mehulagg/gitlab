# frozen_string_literal: true

module Analytics
  class ProductivityAnalyticsRequestParams
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Attributes

    DEFAULT_DATE_RANGE = 30.days

    attr_writer :label_name

    attribute :merged_after, :datetime
    attribute :merged_before, :datetime
    attribute :author_username, :string
    attribute :milestone_title, :string

    attr_accessor :group, :project

    validates :group, presence: true
    validates :merged_after, presence: true
    validates :merged_before, presence: true

    validate :validate_merged_after_is_earlier_than_merged_before
    validate :validate_merged_before
    validate :validate_merged_after

    def initialize(params = {})
      params[:merged_before] ||= Date.today.at_end_of_day
      params[:merged_after] ||= default_merged_after

      super(params)
    end

    def label_name
      Array(@label_name)
    end

    def to_data_attributes
      {}.tap do |attrs|
        attrs[:group] = group_data_attributes if group
        attrs[:project] = project_data_attributes if project
        attrs[:author_username] = author_username
        attrs[:label_name] = label_name.any? ? label_name.join(',') : nil
        attrs[:milestone_title] = milestone_title
        attrs[:merged_after] = merged_after.iso8601
        attrs[:merged_before] = merged_before.iso8601
      end.compact
    end

    def to_default_data_attributes
      { merged_after: merged_after.iso8601, merged_before: merged_before.iso8601 }
    end

    private

    def group_data_attributes
      {
        id: group.id,
        name: group.name,
        full_path: group.full_path,
        avatar_url: group.avatar_url
      }
    end

    def project_data_attributes
      {
        id: project.id,
        gid: project.to_gid.to_s,
        name: project.name,
        path_with_namespace: project.path_with_namespace,
        avatar_url: project.avatar_url
      }
    end

    def validate_merged_after_is_earlier_than_merged_before
      return if merged_after.nil? || merged_before.nil?
      return if merged_after <= merged_before

      errors.add(:merged_before, s_('ProductivityAnalytics|is earlier than the given merged at after date'))
    end

    def validate_merged_before
      return unless merged_before

      validate_against_productivity_analytics_start_date(:merged_before, merged_before)
    end

    def validate_merged_after
      return unless merged_after

      validate_against_productivity_analytics_start_date(:merged_after, merged_after)
    end

    def validate_against_productivity_analytics_start_date(attribute_name, value)
      return unless productivity_analytics_start_date
      return if value >= productivity_analytics_start_date

      errors.add(attribute_name, s_('ProductivityAanalytics|is earlier than the allowed minimum date'))
    end

    def productivity_analytics_start_date
      @productivity_analytics_start_date ||= ApplicationSetting.current&.productivity_analytics_start_date&.beginning_of_day
    end

    # Providing default value for `merged_after` and prevent setting the value to a datetime where we don't have data (`productivity_analytics_start_date`).
    def default_merged_after
      default_value = DEFAULT_DATE_RANGE.ago.to_time.utc.beginning_of_day

      if productivity_analytics_start_date && productivity_analytics_start_date > default_value
        productivity_analytics_start_date
      else
        default_value
      end
    end
  end
end
