# frozen_string_literal: true

# Placeholder class for model that is implemented in EE
class EpicBoardPosition < ApplicationRecord

end

EpicBoardPosition.prepend_if_ee('EE::EpicBoardPosition')
