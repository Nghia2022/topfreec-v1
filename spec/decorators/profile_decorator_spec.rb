# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfileDecorator do
  subject { described_class.new(model) }
  let(:model) { FactoryBot.build(:sf_contact) }

  describe '#last_name' do
    it do
      expect(subject.last_name).to eq model.LastName
    end
  end

  describe '#last_name_kana' do
    it do
      expect(subject.last_name_kana).to eq model.Kana_Sei__c
    end
  end

  describe '#first_name' do
    it do
      expect(subject.first_name).to eq model.FirstName
    end
  end

  describe '#first_name_kana' do
    it do
      expect(subject.first_name_kana).to eq model.Kana_Mei__c
    end
  end

  describe '#phone' do
    it do
      expect(subject.phone).to eq model.Phone
    end
  end

  describe '#phone2' do
    it do
      expect(subject.phone2).to eq model.HomePhone
    end
  end

  describe '#zipcode' do
    it do
      expect(subject.MailingPostalCode).to eq '1500012'
    end
  end

  describe '#prefecture' do
    it do
      expect(subject.MailingState).to eq '東京都'
    end
  end

  describe '#city' do
    it do
      expect(subject.MailingCity).to eq '渋谷区広尾１丁目１−３９'
    end
  end

  describe '#building' do
    it do
      expect(subject.MailingStreet).to eq '恵比寿プライムスクエアタワー4F'
    end
  end
end
