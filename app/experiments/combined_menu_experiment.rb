# frozen_string_literal: true

# TODOs
# - super class #publish method shouldn't use gon.global, this will be fixed in an MR: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/55421
# - If we don't see `window.gon.experiment` defined on the client, it may be because
#   `Gon::Base.render_data(nonce: content_security_policy_nonce)` is in the wrong order in
#   app/views/layouts/_head.html.haml
# - We can move the `variant` override below to a module or common place if we still
#   need this behavior going forward after we are more comfortable with the
#   experiment framework.
# - Document how to turn this on with this variant opt-in approach, by making sure the
#   feature flag is in the `:conditional` status by running the chatops command
#   to enable the flag for any user (yourself is fine):
#   `/chatops run feature set --user=my-gitlab-username some_feature true`.
#   Or, in dev, just `Feature.enable(:some_feature)`
#   see `ApplicationExperiment#enabled?` for more context.
class CombinedMenuExperiment < ApplicationExperiment # rubocop:disable Gitlab/NamespacedClass
  # Allow clients to set what variant to use via a URL param.
  # Only needs to be passed when it changes, it will be cached.
  # Eventually this should not be necessary once gitlab-experiment adds support
  # for controlling via chatops commands.
  def variant(value = nil)
    request = context.instance_variable_get(:@request)

    # For example:
    #   https://url/path?combined_menu_experiment_variant=candidate
    #   https://url/path?combined_menu_experiment_variant=control
    value ||= request.params["#{name}_experiment_variant"]

    # Ensure variant which was passed exists
    value = nil if behaviors[value].blank?

    super(value)
  end
end
