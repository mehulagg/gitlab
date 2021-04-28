# frozen_string_literal: true

require 'uri'

module Banzai
  module Filter
    class BaseRelativeLinkFilter < HTML::Pipeline::Filter
      include Gitlab::Utils::StrongMemoize

      protected

      def linkable_attributes
        if Feature.enabled?(:optimize_linkable_attributes, project, default_enabled: :yaml)
          # Nokorigi Nodeset#search performs badly for documents with many nodes
          #
          # Here we store fetched attributes in the shared variable "result"
          # This variable is passed through the chain of filters and can be
          # accessed by them
          result[:linkable_attributes] ||= fetch_linkable_attributes
        else
          strong_memoize(:linkable_attributes) do
            fetch_linkable_attributes
          end
        end
      end

      def relative_url_root
        Gitlab.config.gitlab.relative_url_root.presence || '/'
      end

      def project
        context[:project]
      end

      private

      def unescape_and_scrub_uri(uri)
        Addressable::URI.unescape(uri).scrub.delete("\0")
      end

      def fetch_linkable_attributes
        attrs = []

        attr_names = ['href', 'src', 'data-src']
        tag_names = ['a', 'img', 'video', 'audio']
        # we need to add `not(.gfm)` here
        xpath_query = tag_names.product(attr_names).map {|a| ".//#{a[0]}/@#{a[1]}"}.join('|')
        attrs += doc.xpath(xpath_query)

        # maybe we could embed this into the xpath query too? (for the next iteration)
        attrs.reject { |attr| attr.blank? || attr.value.start_with?('//') }
      end
    end
  end
end
