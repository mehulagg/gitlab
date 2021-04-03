# frozen_string_literal: true

module EE
  module UserSerializer
    extend ::Gitlab::Utils::Override

    override :represent
    def represent(resource, opts = {}, entity = nil)
      opts = opts.merge(approval_rules: params[:approval_rules] == 'true') if params[:approval_rules]
      opts = opts.merge(target_branch: params[:target_branch]) if params[:target_branch]

      super(resource, opts, entity)
    end
  end
end
