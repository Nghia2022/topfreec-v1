# frozen_string_literal: true

RSpec.describe Projects::JobPostingPrinter do
  let(:printer) { described_class.new(project) }
  let(:project) do
    FactoryBot.build_stubbed(
      :project,
      web_schema_title__c:               'JobPosting title',
      web_schema_description__c:         'JobPosting description',
      web_schema_emptype__c:             'FULL_TIME',
      web_schema_region__c:              '東京都',
      web_expiredatetime__c:             Date.current,
      web_schema_basesalary_min__c:      100,
      web_schema_basesalary_max__c:      200,
      web_schemaquantitativeunittext__c: 'unit',
      jobposting_joblocationtype__c:     job_location_type,
      jobposting_isactive__c:            is_active
    )
  end
  let(:job_location_type) { false }
  let(:is_active) { true }

  describe '#render' do
    subject { printer.render }

    it 'JobPosting 構造化データを返す' do
      expect(JSON.parse(subject)).to include(
        '@context' => 'https://schema.org/',
        '@type' => 'JobPosting',
        'title' => 'JobPosting title',
        'description' => 'JobPosting description',
        'datePosted' => String,
        'validThrough' => String,
        'employmentType' => 'FULL_TIME',
        'hiringOrganization' => include(
          '@type' => 'Organization',
          'name' => '株式会社みらいワークス',
          'sameAs' => 'https://www.mirai-works.co.jp/'
        ),
        'baseSalary' => include(
          '@type' => 'MonetaryAmount',
          'currency' => 'JPY',
          'value' => include(
            '@type' => 'QuantitativeValue',
            'minValue' => 100,
            'maxValue' => 200,
            'unitText' => 'unit'
          )
        ),
        'jobLocation' => include(
          '@type' => 'Place',
          'address' => include(
            '@type' => 'PostalAddress',
            'addressRegion' => '東京都',
            'addressCountry' => 'Japan'
          )
        )
      )
    end

    context 'when job_location_type is true' do
      let(:job_location_type) { true }

      it 'includes applicantLocationRequirements' do
        expect(JSON.parse(subject)).to include(
          '@context' => 'https://schema.org/',
          '@type' => 'JobPosting',
          'title' => 'JobPosting title',
          'description' => 'JobPosting description',
          'datePosted' => String,
          'validThrough' => String,
          'employmentType' => 'FULL_TIME',
          'hiringOrganization' => include(
            '@type' => 'Organization',
            'name' => '株式会社みらいワークス',
            'sameAs' => 'https://www.mirai-works.co.jp/'
          ),
          'applicantLocationRequirements' => {
            '@type' => 'Country',
            'name' => '日本'
          },
          'jobLocationType' => 'TELECOMMUTE'
        )
      end
    end
  end
end
