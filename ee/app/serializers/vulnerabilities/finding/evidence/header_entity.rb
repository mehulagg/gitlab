# frozen_string_literal: true

class Vulnerabilities::Finding::Evidence::HeaderEntity < Grape::Entity
  expose :name
  expose :value
end
