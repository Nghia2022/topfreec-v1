# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorIndicationFormBuilder, type: :model do
  include ActionView::Helpers::FormHelper
  include ErrorIndicationFormBuilder

  let(:klass) do
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :foo

      class << self
        def model_name
          ActiveModel::Name.new(self, nil, 'TestModel')
        end
      end
    end
  end
  let(:object) { klass.new }

  describe '#feedback' do
    subject do
      Capybara.string(feedback(:foo))
    end

    context 'when object has no errors' do
      it do
        expect(feedback(:foo)).to be_nil
      end
    end

    context 'when object has a error' do
      before do
        object.errors.add(:foo, :invalid)
      end

      it do
        is_expected.to have_selector('ul', count: 1)
          .and have_selector('ul>li', count: 1)
      end
    end

    context 'when object has errors' do
      let(:count) { 2 }

      before do
        count.times do
          object.errors.add(:foo, :invalid)
        end
      end

      it do
        is_expected.to have_selector('ul')
          .and have_selector('ul>li', count:)
      end
    end

    describe 'with options[:feedback]' do
      before do
        object.errors.add(:foo, :invalid)
      end

      context 'with container_tag' do
        subject do
          Capybara.string(feedback(:foo, feedback: { container_tag: :div }))
        end

        it do
          is_expected.to have_selector('div', count: 1)
        end
      end

      context 'with item_tag' do
        subject do
          Capybara.string(feedback(:foo, feedback: { item_tag: :div }))
        end

        it do
          is_expected.to have_selector('div', count: 1)
        end
      end
    end
  end

  describe '#select' do
    subject do
      form_with model: object, url: '', builder: AppFormBuilder do |f|
        f.select(:foo)
      end
    end

    xit do
      expect(self).to receive(:feedback)
      subject
    end
  end

  describe '#text_field', :focus do
    subject do
      form_with model: object, url: '', builder: AppFormBuilder do |f|
        f.text_field(:foo)
      end
    end

    xit do
      expect(self).to receive(:feedback)
      subject
    end
  end
end
