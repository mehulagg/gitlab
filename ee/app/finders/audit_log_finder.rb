# frozen_string_literal: true

class AuditLogFinder
  include CreatedAtFilter
  include FinderMethods

  InvalidLevelTypeError = Class.new(StandardError)

  VALID_ENTITY_TYPES = %w[Project User Group].freeze

  # Instantiates a new finder
  #
  # @param [Levels::Project, Levels::Group, Levels::Instance] level that results should be scoped to
  # @param [Hash] params for filtering and sorting
  # @option params [String] :entity_type
  # @option params [Integer] :entity_id
  # @option params [DateTime] :created_after from created_at date
  # @option params [DateTime] :created_before to created_at date
  # @option params [String] :sort order by field_direction (e.g. created_asc)
  #
  # @return [AuditLogFinder]
  def initialize(level:, params: {})
    @level = level
    @params = params
  end

  # Filters and sorts records
  #
  # @return [AuditEvent::ActiveRecord_Relation]
  def execute
    audit_events = init_collection
    audit_events = by_entity(audit_events)
    audit_events = by_created_at(audit_events)
    audit_events = by_author(audit_events)

    sort(audit_events)
  end

  private

  attr_reader :level, :params

  def init_collection
    raise InvalidLevelTypeError unless valid_level_type?

    level.apply
  end

  def valid_level_type?
    level.class.name.include?('Gitlab::Audit::Levels')
  end

  def by_entity(audit_events)
    return audit_events unless valid_entity_type?

    audit_events = audit_events.by_entity_type(params[:entity_type])

    if valid_entity_id?
      audit_events = audit_events.by_entity_id(params[:entity_id])
    end

    audit_events
  end

  def by_author(audit_events)
    return audit_events unless valid_author_id?

    audit_events.by_author_id(params[:author_id])
  end

  def sort(audit_events)
    audit_events.order_by(params[:sort])
  end

  def valid_entity_type?
    VALID_ENTITY_TYPES.include? params[:entity_type]
  end

  def valid_entity_id?
    params[:entity_id].to_i.nonzero?
  end

  def valid_author_id?
    params[:author_id].to_i.nonzero?
  end
end
