# frozen_string_literal: true

class Vulnerabilities::FindingLinkEntity < Grape::Entity
  expose :name
  expose :url
end
