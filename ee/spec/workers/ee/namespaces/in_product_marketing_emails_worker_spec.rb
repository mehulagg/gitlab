# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::InProductMarketingEmailsWorker, '#perform' do
  using RSpec::Parameterized::TableSyntax

  context 'not on gitlab.com' do
    let(:is_gitlab_com) { false }
    let(:license) { build(:license) }

    where(:in_product_marketing_emails_enabled, :experiment_active, :executes_service) do
      true     | true     | 1
      true     | false    | 1
      false    | false    | 0
      false    | true     | 0
    end

    with_them do
      context 'with a license' do
        before do
          allow(license).to receive(:paid?).and_return(is_paid)
          allow(License).to receive(:current).and_return(license)
        end

        context 'paid' do
          let(:is_paid) { true }
          let(:executes_service) { 0 }

          it_behaves_like 'in-product marketing email'
        end

        context 'free' do
          let(:is_paid) { false }

          it_behaves_like 'in-product marketing email'
        end
      end

      context 'without a license' do
        before do
          allow(License).to receive(:current).and_return(nil)
        end

        it_behaves_like 'in-product marketing email'
      end
    end
  end

  context 'on gitlab.com' do
    let(:is_gitlab_com) { true }

    where(:in_product_marketing_emails_enabled, :experiment_active, :executes_service) do
      true     | true     | 1
      true     | false    | 0
      false    | false    | 0
      false    | true     | 0
    end

    with_them do
      it_behaves_like 'in-product marketing email'
    end
  end
end
