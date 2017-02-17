$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

module QA
  ##
  # GitLab QA runtime classes, mostly singletons.
  #
  module Runtime
    autoload :User, 'qa/runtime/user'
    autoload :Namespace, 'qa/runtime/namespace'
  end

  ##
  # GitLab QA Scenarios
  #
  module Scenario
    ##
    # Support files
    #
    autoload :Actable, 'qa/scenario/actable'
    autoload :Template, 'qa/scenario/template'

    ##
    # Test scenario entrypoints.
    #
    module Test
      autoload :Instance, 'qa/scenario/test/instance'
    end

    ##
    # GitLab instance scenarios.
    #
    module Gitlab
      module Project
        autoload :Create, 'qa/scenario/gitlab/project/create'
      end

      module License
        autoload :Add, 'qa/scenario/gitlab/license/add'
      end
    end
  end

  ##
  # Classes describing structure of GitLab, pages, menus etc.
  #
  # Needed to execute click-driven-only black-box tests.
  #
  module Page
    autoload :Base, 'qa/page/base'

    module Main
      autoload :Entry, 'qa/page/main/entry'
      autoload :Menu, 'qa/page/main/menu'
      autoload :Groups, 'qa/page/main/groups'
      autoload :Projects, 'qa/page/main/projects'
    end

    module Project
      autoload :New, 'qa/page/project/new'
      autoload :Show, 'qa/page/project/show'
    end

    module Admin
      autoload :Menu, 'qa/page/admin/menu'
      autoload :License, 'qa/page/admin/license'
    end
  end

  ##
  # Classes describing operations on Git repositories.
  #
  module Git
    autoload :Repository, 'qa/git/repository'
  end

  ##
  # Classes that make it possible to execute features tests.
  #
  module Specs
    autoload :Config, 'qa/specs/config'
    autoload :Runner, 'qa/specs/runner'
  end
end
