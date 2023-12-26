# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RestforceFactory, type: :lib do
  describe '.new_client' do
    it { expect(RestforceFactory.new_client).to be_an_instance_of(Restforce::Data::Client) }
  end
end
