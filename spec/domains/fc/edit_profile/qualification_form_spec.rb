# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fc::EditProfile::QualificationForm, type: :model do
  describe 'validations' do
    let(:form) { described_class.new }
    subject { form }

    it do
      is_expected.to validate_length_of(:license).is_at_most(500)
    end
  end
end
