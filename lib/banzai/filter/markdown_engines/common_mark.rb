# frozen_string_literal: true

# `CommonMark` markdown engine for GitLab's Banzai markdown filter.
# This module is used in Banzai::Filter::MarkdownFilter.
# Used gem is `commonmarker` which is a ruby wrapper for libcmark (CommonMark parser)
# including GitHub's GFM extensions.
# Homepage: https://github.com/gjtorikian/commonmarker

module Banzai
  module Filter
    module MarkdownEngines
      class CommonMark
        EXTENSIONS = [
          :autolink,      # provides support for automatically converting URLs to anchor tags.
          :strikethrough, # provides support for strikethroughs.
          :table,         # provides support for tables.
          :tagfilter      # strips out several "unsafe" HTML tags from being used: https://github.github.com/gfm/#disallowed-raw-html-extension-
        ].freeze

        PARSE_OPTIONS = [
          :FOOTNOTES,                  # parse footnotes.
          :STRIKETHROUGH_DOUBLE_TILDE, # parse strikethroughs by double tildes (as redcarpet does).
          :VALIDATE_UTF8               # replace illegal sequences with the replacement character U+FFFD.
        ].freeze

        RENDER_OPTIONS = [
          :GITHUB_PRE_LANG, # use GitHub-style <pre lang> for fenced code blocks.
          :UNSAFE           # allow raw/custom HTML and unsafe links.
        ].freeze

        RENDER_OPTIONS_SOURCEPOS = RENDER_OPTIONS + [
          :SOURCEPOS # enable embedding of source position information.
        ].freeze

        def initialize(context)
          @context  = context
          @renderer = CommonMarker::HtmlRenderer.new(options: render_options)
        end

        def render(text)
          doc = CommonMarker.render_doc(text, PARSE_OPTIONS, EXTENSIONS)

          @renderer.render(doc)
        end

        private

        def render_options
          @context[:no_sourcepos] ? RENDER_OPTIONS : RENDER_OPTIONS_SOURCEPOS
        end
      end
    end
  end
end
