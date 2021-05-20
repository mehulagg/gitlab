# frozen_string_literal: true

class Vulnerabilities::Finding::Evidence::RequestEntity < Grape::Entity
  expose :method
  expose :url
  expose :body
  expose :headers, using: Vulnerabilities::Finding::Evidence::HeaderEntity
end
