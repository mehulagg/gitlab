# frozen_string_literal: true

# EventCreateService class
#
# Used for creating events feed on dashboard after certain user action
#
# Ex.
#   EventCreateService.new.new_issue(issue, current_user)
#
class EventCreateService
  IllegalActionError = Class.new(StandardError)
  TIMEBOXES = %w(milestone sprint).freeze

  def open_issue(issue, current_user)
    create_record_event(issue, current_user, Event::CREATED)
  end

  def close_issue(issue, current_user)
    create_record_event(issue, current_user, Event::CLOSED)
  end

  def reopen_issue(issue, current_user)
    create_record_event(issue, current_user, Event::REOPENED)
  end

  def open_mr(merge_request, current_user)
    create_record_event(merge_request, current_user, Event::CREATED)
  end

  def close_mr(merge_request, current_user)
    create_record_event(merge_request, current_user, Event::CLOSED)
  end

  def reopen_mr(merge_request, current_user)
    create_record_event(merge_request, current_user, Event::REOPENED)
  end

  def merge_mr(merge_request, current_user)
    create_record_event(merge_request, current_user, Event::MERGED)
  end

  TIMEBOXES.each do |timebox_name|
    define_method(:"open_#{timebox_name}") do |timebox, current_user|
      create_record_event(timebox, current_user, Event::CREATED)
    end

    define_method(:"close_#{timebox_name}") do |timebox, current_user|
      create_record_event(timebox, current_user, Event::CLOSED)
    end

    define_method(:"reopen_#{timebox_name}") do |timebox, current_user|
      create_record_event(timebox, current_user, Event::REOPENED)
    end

    define_method(:"destroy_#{timebox_name}") do |timebox, current_user|
      create_record_event(timebox, current_user, Event::DESTROYED)
    end
  end

  def leave_note(note, current_user)
    create_record_event(note, current_user, Event::COMMENTED)
  end

  def join_project(project, current_user)
    create_event(project, current_user, Event::JOINED)
  end

  def leave_project(project, current_user)
    create_event(project, current_user, Event::LEFT)
  end

  def expired_leave_project(project, current_user)
    create_event(project, current_user, Event::EXPIRED)
  end

  def create_project(project, current_user)
    create_event(project, current_user, Event::CREATED)
  end

  def push(project, current_user, push_data)
    create_push_event(PushEventPayloadService, project, current_user, push_data)
  end

  def bulk_push(project, current_user, push_data)
    create_push_event(BulkPushEventPayloadService, project, current_user, push_data)
  end

  # Create a new wiki page event
  #
  # @param [WikiPage::Meta] wiki_page_meta The event target
  # @param [User] current_user The event author
  # @param [Integer] action One of the Event::WIKI_ACTIONS
  def wiki_event(wiki_page_meta, current_user, action)
    return unless Feature.enabled?(:wiki_events)

    raise IllegalActionError, action unless Event::WIKI_ACTIONS.include?(action)

    create_record_event(wiki_page_meta, current_user, action)
  end

  private

  def create_record_event(record, current_user, status)
    create_event(record.resource_parent, current_user, status, target_id: record.id, target_type: record.class.name)
  end

  def create_push_event(service_class, project, current_user, push_data)
    # We're using an explicit transaction here so that any errors that may occur
    # when creating push payload data will result in the event creation being
    # rolled back as well.
    event = Event.transaction do
      new_event = create_event(project, current_user, Event::PUSHED)

      service_class.new(new_event, push_data).execute

      new_event
    end

    Users::LastPushEventService.new(current_user)
      .cache_last_push_event(event)

    Users::ActivityService.new(current_user).execute
  end

  def create_event(resource_parent, current_user, status, attributes = {})
    attributes.reverse_merge!(
      action: status,
      author_id: current_user.id
    )

    resource_parent_attr = case resource_parent
                           when Project
                             :project
                           when Group
                             :group
                           end
    attributes[resource_parent_attr] = resource_parent if resource_parent_attr

    Event.create!(attributes)
  end
end

EventCreateService.prepend_if_ee('EE::EventCreateService')
