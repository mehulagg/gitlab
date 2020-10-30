# frozen_string_literal: true

module Gitlab
  module WhatsNew
    class ItemPresenter
      def self.present(item)
        if Gitlab.com?
          item['packages'] = item['packages'].map { |p| dictionary[p.downcase.to_sym] }
        end

        item
      end

      def self.dictionary
        {
          'free': 'Free',
          'starter': 'Bronze',
          'premium': 'Silver',
          'ultimate': 'Gold'
        }
      end
    end
  end
end
