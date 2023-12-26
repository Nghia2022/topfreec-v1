# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cases::CaseForm, type: :model do
  let(:model) { described_class.new(FactoryBot.attributes_for(:case_form, confirming: '1')) }

  describe 'validations' do
    subject { model }

    it do
      is_expected
        .to validate_presence_of(:email)
        .and validate_confirmation_of(:email)
        .and validate_presence_of(:last_name)
        .and validate_presence_of(:first_name)
        .and validate_presence_of(:last_name_kana)
        .and validate_presence_of(:first_name_kana)
        .and validate_presence_of(:case_type)
        .and validate_presence_of(:description)
        .and validate_length_of(:email).is_at_most(80)
        .and validate_length_of(:phone).is_at_most(40)
        .and validate_length_of(:description).is_at_most(1000)
    end

    describe 'name length validation' do
      context 'total length is 80 characters or less' do
        it do
          is_expected.to be_valid
        end
      end

      context 'total length is over 80 characters' do
        before do
          model.assign_attributes(
            last_name:       'a' * 30,
            first_name:      'b' * 30,
            last_name_kana:  'c' * 30,
            first_name_kana: 'd' * 30
          )
        end

        it do
          is_expected.to be_invalid
        end
      end
    end
  end

  describe '#serialize' do
    subject { model.serialize }

    it do
      is_expected.to include(
        :email,
        :last_name,
        :first_name,
        :last_name_kana,
        :first_name_kana,
        :phone,
        :case_type,
        :description
      )
    end
  end

  describe '#save' do
    context 'if saved' do
      before do
        allow_any_instance_of(Restforce::Data::Client).to receive(:create!).and_return(true)
      end

      it do
        expect { model.save }.to change(model, :persisted?).from(false).to(true)
      end
    end

    context 'if saving failed' do
      before do
        allow_any_instance_of(Restforce::Data::Client).to receive(:create!).and_raise(
          Restforce::ErrorCode::StringTooLong, 'STRING_TOO_LONG'
        )
      end

      it do
        model.save
        expect(model.errors).to be_has_key(:base)
      end
    end
  end
end
