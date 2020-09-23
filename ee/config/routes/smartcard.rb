# frozen_string_literal: true

resource :smartcard, only: [], controller: :smartcard do
  collection do
    post :auth
    get :extract_certificate
    get :verify_certificate
  end
end
