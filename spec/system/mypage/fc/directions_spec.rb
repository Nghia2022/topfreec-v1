# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Directions', type: :system, js: true do
  describe 'pagerizer' do
    let_it_be(:directions_count) { 50 }
    let_it_be(:fc_user) { FactoryBot.create(:fc_user, :activated) }
    let_it_be(:directions) { FactoryBot.create_list(:direction, directions_count, :waiting_for_fc, :with_project, project_trait: [fc_account: fc_user.account, main_fc_contact: fc_user.contact]) }
    let(:account) { FactoryBot.build_stubbed(:sf_account_fc) }

    before do
      allow_any_instance_of(Account).to receive(:to_sobject).and_return(account)
      sign_in(fc_user)
    end

    it do
      visit mypage_fc_directions_url

      expect(page).to have_selector(:testid, 'fc/direction/item', count: 25)
    end
  end
end
