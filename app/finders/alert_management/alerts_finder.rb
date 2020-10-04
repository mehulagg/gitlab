# frozen_string_literal: true

module AlertManagement
  class AlertsFinder
    
    # This is used as a common filter for None / Any
    FILTER_NONE = 'none'
    FILTER_ANY = 'any'

    # This is used in unassigning users
    NONE = '0'

    # @return [Hash<Integer,Integer>] Mapping of status id to count
    #          ex) { 0: 6, ...etc }
    def self.counts_by_status(current_user, project, params = {})
      new(current_user, project, params).execute.counts_by_status
    end

    def initialize(current_user, project, params)
      @current_user = current_user
      @project = project
      @params = params
    end

    def execute
      return AlertManagement::Alert.none unless authorized?

      collection = project.alert_management_alerts
      collection = by_status(collection)
      collection = by_search(collection)
      collection = by_author(collection)
      collection = by_assignee(collection)
      collection = by_iid(collection)
      sort(collection)
    end

    private

    attr_reader :current_user, :project, :params

    def present?
      params.present?
    end

    def author_id?
      params[:author_id].present? && params[:author_id] != NONE
    end

    def author_username?
      params[:author_username].present? && params[:author_username] != NONE
    end

    def no_author?
      # author_id takes precedence over author_username
      params[:author_id] == NONE || params[:author_username] == NONE
    end

    def filter_by_no_assignee?
      params[:assignee_id].to_s.downcase == FILTER_NONE
    end

    def filter_by_any_assignee?
      params[:assignee_id].to_s.downcase == FILTER_ANY
    end

    def by_iid(collection)
      return collection unless params[:iid]

      collection.for_iid(params[:iid])
    end

    def by_status(collection)
      values = AlertManagement::Alert::STATUSES.values & Array(params[:status])

      values.present? ? collection.for_status(values) : collection
    end

    def by_search(collection)
      params[:search].present? ? collection.search(params[:search]) : collection
    end

    def sort(collection)
      params[:sort] ? collection.sort_by_attribute(params[:sort]) : collection
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def by_author(collection)
      if params.author
        collection.where(author_id: params.author.id)
      elsif params.no_author?
        collection.where(author_id: nil)
      elsif params.author_id? || params.author_username? # author not found
        collection.none
      else
        collection
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def by_assignee(collection)
      if params.filter_by_no_assignee?
        collection.unassigned
      elsif params.filter_by_any_assignee?
        collection.assigned
      elsif params.assignee
        collection.assigned_to(params.assignee)
      elsif params.assignee_id? || params.assignee_username? # assignee not found
        collection.none
      else
        collection
      end
    end

    def authorized?
      Ability.allowed?(current_user, :read_alert_management_alert, project)
    end
  end
end
