# frozen_string_literal: true

class Vulnerabilities::Finding::EvidenceEntity < Grape::Entity
  expose :summary
  expose :request, using: Vulnerabilities::Finding::Evidence::RequestEntity
  expose :response, using: Vulnerabilities::Finding::Evidence::ResponseEntity
end
