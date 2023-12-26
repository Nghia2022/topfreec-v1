# frozen_string_literal: true

shared_examples_for 'sobject' do |sobject_name|
  describe '.sobject_name' do
    it { expect(described_class.sobject_name).to eq sobject_name }
  end
end
