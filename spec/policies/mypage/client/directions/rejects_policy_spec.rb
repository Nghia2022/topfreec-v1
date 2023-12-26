# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Client::Directions::RejectsPolicy, type: :policy do
  describe 'permissions' do
    subject { described_class.new(user, model) }

    let(:user) { FactoryBot.build_stubbed(:client_user, :with_contact) }
    let(:contact) { user.contact }
    let(:project) { FactoryBot.create(:project, main_cl_contact: contact) }

    context 'project owner client user' do
      context 'status is waiting_for_client' do
        let(:model) { FactoryBot.build_stubbed(:direction, :waiting_for_client, project:) }

        it do
          is_expected.to permit_actions(%i[show create])
        end
      end

      shared_examples 'with status cannot be processed' do
        it do
          is_expected.to forbid_actions(%i[show create])
        end
      end

      context 'status is waiting_for_fc' do
        let(:model) { FactoryBot.build_stubbed(:direction, :in_prepare, project:) }

        it_behaves_like 'with status cannot be processed'
      end

      context 'status is waiting_for_fc' do
        let(:model) { FactoryBot.build_stubbed(:direction, :waiting_for_fc, project:) }

        it_behaves_like 'with status cannot be processed'
      end

      context 'status is rejected by client' do
        let(:model) { FactoryBot.build_stubbed(:direction, :rejected_by_client, project:) }

        it_behaves_like 'with status cannot be processed'
      end

      context 'status is rejected by fc' do
        let(:model) { FactoryBot.build_stubbed(:direction, :rejected_by_fc, project:) }

        it_behaves_like 'with status cannot be processed'
      end

      context 'status is completed' do
        let(:model) { FactoryBot.build_stubbed(:direction, :completed, project:) }

        it_behaves_like 'with status cannot be processed'
      end
    end

    context 'not project owner' do
      let(:model) { FactoryBot.build_stubbed(:direction, :waiting_for_client, project:) }
      let(:contact) { FactoryBot.build_stubbed(:contact) }

      it do
        is_expected.to forbid_actions(%i[show create])
      end
    end
  end
end
