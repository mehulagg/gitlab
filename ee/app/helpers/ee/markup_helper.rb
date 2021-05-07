# frozen_string_literal: true

module EE
  module MarkupHelper
    extend ::Gitlab::Utils::Override

    private

    override :render_wiki_content_context_container
    def render_wiki_content_context_container(wiki)
      if wiki.container.is_a?(Project)
        super
      else
        { project: nil, group: wiki.container }
      end
    end
  end
end
