# frozen_string_literal: true

module EE
  module MergeRequestSerializer
    extend ::Gitlab::Utils::Override

    override :represent
    def represent(merge_request, opts = {}, entity = nil)
      entity ||=
        case opts[:serializer]
        when 'compliance_dashboard'
          MergeRequestComplianceEntity
        end

      super(merge_request, opts, entity)
    end
  end
end
