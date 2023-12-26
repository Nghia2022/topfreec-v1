# frozen_string_literal: true

shared_examples_for 'validate_zipcode' do |column|
  describe "##{column}" do
    it do
      is_expected.to allow_value('0791143').for(column)
        .and not_allow_value('079-1143').for(column)
        .and not_allow_value('abcdefg').for(column)
        .and not_allow_value('079114').for(column)
    end
  end
end
