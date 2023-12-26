# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LandingPagePolicy, type: :policy do
  subject { described_class.new(user, model) }
  let(:user) { nil }
  let(:model) { LandingPages::RegistrationForm.new }

  describe '#permitted_attributes' do
    it do
      is_expected.to permit_mass_assignment_of(%i[email last_name first_name last_name_kana first_name_kana phone work_area1 work_area2 work_area3])
    end
  end
end
