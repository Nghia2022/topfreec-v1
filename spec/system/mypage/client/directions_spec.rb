# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Client::Directions', type: :system, js: true do
  describe '#show' do
    let_it_be(:directions_count) { 50 }
    let_it_be(:client_user) { FactoryBot.create(:client_user, :with_contact) }
    let_it_be(:directions) { FactoryBot.create_list(:direction, directions_count, :waiting_for_client, :with_project, project_trait: [client: client_user.account, main_cl_contact: client_user.contact]) }
    let(:account) { FactoryBot.build_stubbed(:sf_account_client) }

    before do
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(account)
      sign_in(client_user)
    end

    it do
      visit mypage_client_directions_url

      expect(page).to have_selector(:testid, 'client/direction/item/row', count: 25, visible: false)
    end
  end
end
