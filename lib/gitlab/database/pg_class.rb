# frozen_string_literal: true

module Gitlab
  module Database
    class PgClass < ActiveRecord::Base
      self.primary_key = nil
      self.table_name = 'pg_class'
    end
  end
end
