# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchingDecorator do
  subject { described_class.new(model) }
  let(:model) { FactoryBot.build(:matching) }

  describe 'delegations' do
    it do
      is_expected
        .to  delegate_method(:project_name).to(:project)
        .and delegate_method(:compensation).to(:project)
    end
  end

  describe '#selection_status' do
    pending # TODO: MW内部の表現を`エントリー`用の表現に変換する
  end

  describe '#application_date' do
    let(:model) { FactoryBot.build(:matching, createddate: Time.current) }

    it do
      expect(subject.application_date).to eq model.createddate
    end
  end
end
