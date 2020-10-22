# frozen_string_literal: true

class Vulnerabilities::FindingSerializer < BaseSerializer
  include WithPagination

  entity Vulnerabilities::FindingEntity

  def represent(resource, opts = {})
    if paginated?
      resource = paginator.paginate(resource)
    end

    if opts.delete(:preload)
      resource = Gitlab::Vulnerabilities::FindingsPreloader.preload!(resource)
    end

    super(resource, opts)
  end
end
