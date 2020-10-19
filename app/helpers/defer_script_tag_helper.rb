# frozen_string_literal: true

module DeferScriptTagHelper
  # Override the default ActionView `javascript_include_tag` helper to support page specific deferred loading
  # --------
  # WARNING:
  # The FE entrypoints are now dependent on `defer` ordering so this is critical.
  # Otherwise, we could end up running the FE script when the DOM is not ready yet.
  # Please see https://gitlab.com/groups/gitlab-org/-/epics/4538#note_432159769.
  # --------
  def javascript_include_tag(*sources)
    super(*sources, defer: true)
  end
end
