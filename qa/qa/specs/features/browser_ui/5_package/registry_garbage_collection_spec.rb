# frozen_string_literal: true

module QA
    RSpec.describe 'Package' do
      describe 'Container Registry Garbage Collection', :registry_gc, only: { subdomain: %i[pre] } do

        it 'runs!' do
          Flow::Login.sign_in
        end
      end
    end
end
