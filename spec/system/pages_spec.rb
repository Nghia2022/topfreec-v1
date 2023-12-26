# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :system, js: true do
  describe '#support' do
    context 'when click nomura ideco link' do
      it do
        visit support_page_url

        click_button('『野村證券のiDeCo』への')

        expect(page.current_url).to eq(nomura_ideco_url)
      end
    end
  end
end
