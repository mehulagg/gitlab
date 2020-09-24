# frozen_string_literal: true

class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    @subscription_ids = []
  end

  def execute(data)
    query = data['query']
    variables = Gitlab::Graphql::Variables.new(data['variables']).to_h
    operation_name = data['operationName']

    # You may want to keep this in sync with GraphqlController#context so that we
    # have the same context when executing queries, mutations, and subscriptions
    context = {
      channel: self,
      current_user: current_user
    }

    result = GitlabSchema.execute({
      query: query,
      context: context,
      variables: variables,
      operation_name: operation_name
    })

    payload = {
      result: result.to_h,
      more: result.subscription?
    }

    # Track the subscription here so we can remove it
    # on unsubscribe.
    if result.context[:subscription_id]
      @subscription_ids << result.context[:subscription_id]
    end

    transmit(payload)
  end

  def unsubscribed
    @subscription_ids.each do |sid|
      GitlabSchema.subscriptions.delete_subscription(sid)
    end
  end

  rescue_from Gitlab::Graphql::Variables::Invalid do |exception|
    transmit({ errors: [{ message: exception.message }] })
  end
end
