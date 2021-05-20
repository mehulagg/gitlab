# frozen_string_literal: true

class Vulnerabilities::Finding::Evidence::ResponseEntity < Grape::Entity
  expose :reason_phrase
  expose :body
  expose :headers, using: Vulnerabilities::Finding::Evidence::HeaderEntity
end
