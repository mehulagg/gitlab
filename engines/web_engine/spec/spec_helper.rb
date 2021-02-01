# frozen_string_literal: true

Dir[WebEngine::Engine.root.join("spec/support/helpers/*.rb")].sort.each { |f| require f }
Dir[WebEngine::Engine.root.join("spec/support/shared_contexts/*.rb")].sort.each { |f| require f }
Dir[WebEngine::Engine.root.join("spec/support/shared_examples/**/*.rb")].sort.each { |f| require f }
Dir[WebEngine::Engine.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
