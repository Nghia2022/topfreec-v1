# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mypage::Fc::Settings::DesiredConditionCell, :erb, type: :cell do
  controller ApplicationController

  let(:options) { {} }
  let(:described_cell) { cell(described_class, model, options) }
  let(:model) { FactoryBot.build_stubbed(:contact, :fc, desired_condition) }

  context 'cell rendering' do
    describe 'rendering #show' do
      subject { described_cell.call(:show) }

      let(:desired_condition) do
        {
          work_prefecture1__c:         DesiredCondition.work_location1.options.sample.first,
          work_prefecture2__c:         DesiredCondition.work_location2.options.sample.first,
          work_prefecture3__c:         DesiredCondition.work_location3.options.sample.first,
          experienced_works__c:        Contact::ExperiencedWork.all.map(&:value).sample(rand(1..4)),
          desired_works__c:            Contact::DesiredWork.all.map(&:value).sample(rand(1..4)),
          experienced_company_size__c: DesiredCondition.company_sizes.options.map(&:first).sample(rand(1..4)),
          work_options__c:             Contact::WorkOption.all.map(&:value).sample(rand(1..4))
        }
      end

      it do
        is_expected.to have_content(model.work_prefecture1__c)
          .and have_content(model.work_prefecture2__c)
          .and have_content(model.work_prefecture3__c)
          .and have_content(model.experienced_works__c&.join('、'))
          .and have_content(model.desired_works__c&.join('、'))
          .and have_content(model.experienced_company_size__c&.join(' / '))
          .and have_content(model.work_options__c&.join('、'))
      end
    end

    # TODO: #3353 #showに変更
    describe 'rendering #new_show' do
      subject { described_cell.call(:new_show) }

      let(:desired_condition) do
        {
          work_prefecture1__c:         DesiredCondition.work_location1.options.sample.first,
          work_prefecture2__c:         DesiredCondition.work_location2.options.sample.first,
          work_prefecture3__c:         DesiredCondition.work_location3.options.sample.first,
          experienced_works_main__c:   %w[プロジェクト管理 ITプロジェクト管理],
          experienced_works_sub__c:    %w[PM PMO IT・PM],
          desired_works_main__c:       %w[新規事業 IPO],
          desired_works_sub__c:        %w[事業開発（企画） 事業開発（実務） IPO準備],
          experienced_company_size__c: DesiredCondition.company_sizes.options.map(&:first).sample(rand(1..4)),
          work_options__c:             Contact::WorkOption.all.map(&:value).sample(rand(1..4))
        }
      end

      it do
        is_expected.to have_content(model.work_prefecture1__c)
          .and have_content(model.work_prefecture2__c)
          .and have_content(model.work_prefecture3__c)
          .and have_content(model.experienced_company_size__c&.join(' / '))
          .and have_content(model.work_options__c&.join('、'))
          .and have_content('プロジェクト管理: PM、PMO')
          .and have_content('ITプロジェクト管理: IT・PM')
          .and have_content('新規事業: 事業開発（企画）、事業開発（実務）')
          .and have_content('IPO: IPO準備')
      end
    end
  end

  describe 'xss' do
    shared_examples 'returns sanitized html' do
      it do
        is_expected.to eq('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;')
      end
    end

    describe '#business_form' do
      subject { described_cell.business_form }

      let(:desired_condition) do
        {
          work_options__c: ['<script>alert("xss")</script>']
        }
      end

      include_examples 'returns sanitized html'
    end

    describe '#experienced_works' do
      subject { described_cell.experienced_works }

      let(:desired_condition) do
        {
          experienced_works__c: ['<script>alert("xss")</script>']
        }
      end

      include_examples 'returns sanitized html'
    end

    describe '#desired_works' do
      subject { described_cell.desired_works }

      let(:desired_condition) do
        {
          desired_works__c: ['<script>alert("xss")</script>']
        }
      end

      include_examples 'returns sanitized html'
    end

    describe '#company_sizes' do
      subject { described_cell.company_sizes }

      let(:desired_condition) do
        {
          experienced_company_size__c: ['<script>alert("xss")</script>']
        }
      end

      include_examples 'returns sanitized html'
    end

    describe '#work_location1' do
      subject { described_cell.work_location1 }

      let(:desired_condition) do
        {
          work_prefecture1__c: '<script>alert("xss")</script>'
        }
      end

      include_examples 'returns sanitized html'
    end

    describe '#work_location2' do
      subject { described_cell.work_location2 }

      let(:desired_condition) do
        {
          work_prefecture2__c: '<script>alert("xss")</script>'
        }
      end

      include_examples 'returns sanitized html'
    end

    describe '#work_location3' do
      subject { described_cell.work_location3 }

      let(:desired_condition) do
        {
          work_prefecture3__c: '<script>alert("xss")</script>'
        }
      end

      include_examples 'returns sanitized html'
    end
  end
end
