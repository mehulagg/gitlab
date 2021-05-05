# frozen_string_literal: true

require 'fast_spec_helper'
require_relative '../../../rubocop/cop/inject_enterprise_edition_module'

RSpec.describe RuboCop::Cop::InjectEnterpriseEditionModule do
  subject(:cop) { described_class.new }

  it 'flags the use of `prepend_mod_with EE` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      prepend_mod_with 'EE::Foo'
      ^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `prepend_mod_with QA::EE` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      prepend_mod_with 'QA::EE::Foo'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'does not flag the use of `prepend_mod_with EEFoo` in the middle of a file' do
    expect_no_offenses(<<~SOURCE)
    class Foo
      prepend_mod_with 'EEFoo'
    end
    SOURCE
  end

  it 'flags the use of `prepend_mod_with EE::Foo::Bar` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      prepend_mod_with 'EE::Foo::Bar'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `prepend_mod_with(EE::Foo::Bar)` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      prepend_mod_with('Foo::Bar')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `prepend_mod_with EE::Foo::Bar::Baz` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      prepend_mod_with 'EE::Foo::Bar::Baz'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `prepend_mod_with ::EE` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      prepend_mod_with '::EE::Foo'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `include_mod_with EE` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      include_mod_with 'EE::Foo'
      ^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `include_mod_with ::EE` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      include_mod_with '::EE::Foo'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `extend_mod_with EE` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      extend_mod_with 'EE::Foo'
      ^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'flags the use of `extend_mod_with ::EE` in the middle of a file' do
    expect_offense(<<~SOURCE)
    class Foo
      extend_mod_with '::EE::Foo'
      ^^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
    end
    SOURCE
  end

  it 'does not flag prepending of regular modules' do
    expect_no_offenses(<<~SOURCE)
    class Foo
      prepend_mod_with 'Foo'
    end
    SOURCE
  end

  it 'does not flag including of regular modules' do
    expect_no_offenses(<<~SOURCE)
    class Foo
      include_mod_with 'Foo'
    end
    SOURCE
  end

  it 'does not flag extending using regular modules' do
    expect_no_offenses(<<~SOURCE)
    class Foo
      extend_mod_with 'Foo'
    end
    SOURCE
  end

  it 'does not flag the use of `prepend_mod_with EE` on the last line' do
    expect_no_offenses(<<~SOURCE)
    class Foo
    end

    Foo.prepend_mod_with('Foo')
    SOURCE
  end

  it 'does not flag the use of `include_mod_with EE` on the last line' do
    expect_no_offenses(<<~SOURCE)
    class Foo
    end

    Foo.include_mod_with('Foo')
    SOURCE
  end

  it 'does not flag the use of `extend_mod_with EE` on the last line' do
    expect_no_offenses(<<~SOURCE)
    class Foo
    end

    Foo.extend_mod_with('Foo')
    SOURCE
  end

  it 'does not flag the double use of `X_if_ee` on the last line' do
    expect_no_offenses(<<~SOURCE)
    class Foo
    end

    Foo.extend_mod_with('Foo')
    Foo.include_mod_with('Foo')
    Foo.prepend_mod_with('Foo')
    SOURCE
  end

  it 'does not flag the use of `prepend_mod_with EE` as long as all injections are at the end of the file' do
    expect_no_offenses(<<~SOURCE)
    class Foo
    end

    Foo.include_mod_with('Foo')
    Foo.prepend_mod_with('Foo')

    Foo.include(Bar)
    # comment on prepending Bar
    Foo.prepend(Bar)
    SOURCE
  end

  it 'autocorrects offenses by just disabling the Cop' do
    expect_offense(<<~SOURCE)
      class Foo
        prepend_mod_with 'EE::Foo'
        ^^^^^^^^^^^^^^^^^^^^^^^ Injecting EE modules must be done on the last line of this file, outside of any class or module definitions
        include_mod_with 'Bar'
      end
    SOURCE

    expect_correction(<<~SOURCE)
      class Foo
        prepend_mod_with 'EE::Foo' # rubocop: disable Cop/InjectEnterpriseEditionModule
        include_mod_with 'Bar'
      end
    SOURCE
  end

  it 'disallows the use of prepend to inject an EE module' do
    expect_offense(<<~SOURCE)
    class Foo
    end

    Foo.prepend(EE::Foo)
    ^^^^^^^^^^^^^^^^^^^^ EE modules must be injected using `include_mod_with`, `extend_mod_with`, or `prepend_mod_with`
    SOURCE
  end

  it 'disallows the use of prepend to inject a QA::EE module' do
    expect_offense(<<~SOURCE)
    class Foo
    end

    Foo.prepend(QA::EE::Foo)
    ^^^^^^^^^^^^^^^^^^^^^^^^ EE modules must be injected using `include_mod_with`, `extend_mod_with`, or `prepend_mod_with`
    SOURCE
  end

  it 'disallows the use of extend to inject an EE module' do
    expect_offense(<<~SOURCE)
    class Foo
    end

    Foo.extend(EE::Foo)
    ^^^^^^^^^^^^^^^^^^^ EE modules must be injected using `include_mod_with`, `extend_mod_with`, or `prepend_mod_with`
    SOURCE
  end

  it 'disallows the use of include to inject an EE module' do
    expect_offense(<<~SOURCE)
    class Foo
    end

    Foo.include(EE::Foo)
    ^^^^^^^^^^^^^^^^^^^^ EE modules must be injected using `include_mod_with`, `extend_mod_with`, or `prepend_mod_with`
    SOURCE
  end

  it 'disallows the use of prepend_mod_with without a String' do
    expect_offense(<<~SOURCE)
    class Foo
    end

    Foo.prepend_mod_with(EE::Foo)
                      ^^^^^^^ EE modules to inject must be specified as a String
    SOURCE
  end

  it 'disallows the use of include_mod_with without a String' do
    expect_offense(<<~SOURCE)
    class Foo
    end

    Foo.include_mod_with(EE::Foo)
                      ^^^^^^^ EE modules to inject must be specified as a String
    SOURCE
  end

  it 'disallows the use of extend_mod_with without a String' do
    expect_offense(<<~SOURCE)
    class Foo
    end

    Foo.extend_mod_with(EE::Foo)
                     ^^^^^^^ EE modules to inject must be specified as a String
    SOURCE
  end
end
