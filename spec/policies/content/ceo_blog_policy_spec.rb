# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::CeoBlogPolicy, type: :policy do
  subject { described_class.new(user, model) }
  let(:user) { instance_double('User') }

  describe Content::ColumnPolicy::Scope do
    subject(:scope) { described_class.new(user, Wordpress::CeoBlog) }

    describe '#resolve' do
      subject { scope.resolve }

      context 'with wp_user' do
        let(:user) { FactoryBot.build_stubbed(:wp_user) }

        it do
          is_expected.to have_attributes(
            where_values_hash: {
              'post_type' => 'ceo_blog',
              'post_status' => match_array(%i[publish draft])
            }
          )
        end
      end

      context 'with fc_user' do
        let(:user) { FactoryBot.build_stubbed(:fc_user) }

        it do
          is_expected.to have_attributes(
            where_values_hash: {
              'post_type' => 'ceo_blog',
              'post_status' => :publish
            }
          )
        end
      end

      context 'with guest' do
        let(:user) { nil }

        it do
          is_expected.to have_attributes(
            where_values_hash: {
              'post_type' => 'ceo_blog',
              'post_status' => :publish
            }
          )
        end
      end
    end
  end
end
