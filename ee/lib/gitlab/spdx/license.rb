# frozen_string_literal: true

module Gitlab
  module SPDX
    License = Struct.new(:id, :name, :deprecated, keyword_init: true)
  end
end
