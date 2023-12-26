# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailValidator, type: :validator do
  subject(:validator) { described_class.new }

  describe '#validate_each' do
    subject(:validate) do
      record.validate
      record.errors
    end

    let(:model) do
      Class.new do
        include ActiveModel::Model
        include ActiveModel::Attributes
        include ActiveModel::Dirty
        include ActiveModel::Validations

        attribute :email

        validates :email, email: true

        def self.model_name
          ActiveModel::Name.new(self, nil, 'User')
        end
      end
    end
    let(:record) do
      model.new(email:)
    end
    let(:email) { Faker::Internet.email }

    context 'with a valid email' do
      it do
        expect(validate).not_to be_added(:email, :invalid)
      end
    end

    context 'with an invalid email' do
      let(:email) { 'invalid' }

      it do
        expect(validate).to be_added(:email, :invalid)
      end
    end

    context 'with an empty email' do
      let(:email) { nil }

      it do
        expect(validate).not_to be_added(:email, :invalid)
      end
    end
  end
end
