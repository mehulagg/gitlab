# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Wikis::CreateAttachmentService do
  it_behaves_like 'Wikis::CreateAttachmentService#execute', :group
end
