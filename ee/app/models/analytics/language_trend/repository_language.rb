# frozen_string_literal: true

class Analytics::LanguageTrend::RepositoryLanguage < ApplicationRecord
  extend SuppressCompositePrimaryKeyWarning

  belongs_to :programming_language
  belongs_to :project
end
