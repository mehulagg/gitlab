# frozen_string_literal: true

module EE
  module IdeHelper
    extend ::Gitlab::Utils::Override

    override :ide_data
    def ide_data
      super.merge({
        "ee-web-terminal-svg-path" => image_path('illustrations/web-ide_promotion.svg'),
        "ee-web-terminal-help-path" => help_page_path('user/project/web_ide/index.md', anchor: 'interactive-web-terminals-for-the-web-ide'),
        "ee-web-terminal-config-help-path" => help_page_path('user/project/web_ide/index.md', anchor: 'web-ide-configuration-file'),
        "ee-web-terminal-runners-help-path" => help_page_path('user/project/web_ide/index.md', anchor: 'runner-configuration')
      })
    end
  end
end
