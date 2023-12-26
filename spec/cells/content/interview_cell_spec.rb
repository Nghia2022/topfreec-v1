# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Content::InterviewCell, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build_stubbed(:interview).decorate }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      it do
        is_expected.to have_link(model.post_title, href: corp_interview_path(model))
      end
    end

    describe 'rendering #detail' do
      subject { described_cell.call(:detail) }

      before do
        allow(model).to receive(:thumbnail).and_return('http://example.com/')
        allow(model).to receive(:prev_content).and_return(prev_content)
        allow(model).to receive(:next_content).and_return(next_content)
      end

      context 'without prev/next content' do
        let(:prev_content) { nil }
        let(:next_content) { nil }

        it do
          is_expected
            .to have_selector('img[src="http://example.com/"]')
            .and have_selector('.intview-pagi-item.invisible')
        end
      end

      context 'with prev/next content' do
        let(:prev_content) { FactoryBot.build_stubbed(:interview, post_title: 'Prev content').decorate }
        let(:next_content) { FactoryBot.build_stubbed(:interview, post_title: 'Next content').decorate }

        it do
          is_expected
            .to have_selector('img[src="http://example.com/"]')
            .and have_content(prev_content.post_title)
            .and have_content(next_content.post_title)
        end
      end
    end
  end

  describe '#post_date' do
    subject { described_cell.send(:post_date) }

    let(:model) { FactoryBot.build_stubbed(:interview, post_date: Time.zone.parse('2021-03-01 10:00:00')).decorate }

    it do
      is_expected.to eq '2021年3月1日(月)'
    end
  end

  describe '#profile' do
    subject { described_cell.send(:profile) }

    before do
      allow(model).to receive(:profile).and_return('<strong>Profile</strong>')
    end

    it do
      is_expected.to eq '<p>Profile</p>'
    end
  end

  describe '#post_content' do
    subject { described_cell.send(:post_content) }
    let(:model) { FactoryBot.build_stubbed(:interview, post_content: 'Content').decorate }

    it do
      is_expected.to eq '<p>Content</p>'
    end
  end
end
