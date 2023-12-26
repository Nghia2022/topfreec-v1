# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  using ResponseJson

  describe 'theming' do
    subject(:perform) do
      get :index
      response
    end

    controller(described_class) do
      def index
        render json: request.variant.as_json
      end
    end

    before do
      Warden.test_mode!
    end

    context 'with default' do
      it do
        perform
        expect(response.json).to eq []
      end
    end
  end
end
