# frozen_string_literal: true

require 'fast_spec_helper'

require_relative '../../../../rubocop/cop/rspec/empty_line_after_final_let_it_be'

RSpec.describe RuboCop::Cop::RSpec::EmptyLineAfterFinalLetItBe do
  subject(:cop) { described_class.new }

  context 'when no `let_it_be` exists' do
    let(:source) do
      <<~SRC
        RSpec.describe Something do
          let(:foo) { :bar }
        end
      SRC
    end

    it 'does not register any offense' do
      expect_no_offenses(source)
    end
  end

  context 'when `let_it_be` helper method exists' do
    context 'when there is a blank line after the final `let_it_be`' do
      let(:source) do
        <<~SRC
          RSpec.describe Something do
            let_it_be(:foo) { :bar }

            before do
              do_something_important!
            end
          end
        SRC
      end

      it 'does not register any offense' do
        expect_no_offenses(source)
      end
    end

    context 'when there is no blank line after the final `let_it_be`' do
      context 'when the code is not in an example group' do
        let(:source) do
          <<~SRC
            let_it_be(:foo) { :bar }
            before do
              do_something_important!
            end
          SRC
        end

        it 'does not register any offense' do
          expect_no_offenses(source)
        end
      end

      context 'when the code is in an example group' do
        let(:source) do
          <<~SRC
            RSpec.describe Something do
              let_it_be(:foo) { :bar }
              ^^^^^^^^^^^^^^^^^^^^^^^^ Add an empty line after the last `let_it_be`.
              before do
                do_something_important!
              end
            end
          SRC
        end

        it 'registers an offense' do
          expect_offense(source)
        end
      end
    end
  end
end
