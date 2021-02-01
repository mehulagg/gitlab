# frozen_string_literal: true

module GDK
  module Command
    autoload :Config, 'gdk/command/config'
    autoload :DiffConfig, 'gdk/command/diff_config'
    autoload :Doctor, 'gdk/command/doctor'
    autoload :Install, 'gdk/command/install'
    autoload :Measure, 'gdk/command/measure'
    autoload :Help, 'gdk/command/help'
    autoload :Reconfigure, 'gdk/command/reconfigure'
    autoload :Run, 'gdk/command/run'
    autoload :Update, 'gdk/command/update'
  end
end
