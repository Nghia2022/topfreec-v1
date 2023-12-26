# frozen_string_literal: true

shared_examples_for 'validate_phone' do |*columns|
  columns.each do |column|
    describe "##{column}" do
      it do
        is_expected.to allow_value('09012345678').for(column)
          .and allow_value('0121112222').for(column)
          .and not_allow_value('090-1234-5689').for(column)
          .and not_allow_value('012-111-2222').for(column)
          .and not_allow_value('abcdefg').for(column)
          .and not_allow_value('123456').for(column)
      end
    end
  end
end
