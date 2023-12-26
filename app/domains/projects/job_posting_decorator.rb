# frozen_string_literal: true

module Projects
  class JobPostingDecorator < Draper::Decorator
    delegate_all

    alias_attribute :title, :web_schema_title__c
    alias_attribute :description, :web_schema_description__c
    alias_attribute :employment_type, :web_schema_emptype__c
    alias_attribute :address_region, :web_schema_region__c
    alias_attribute :base_salary_min, :web_schema_basesalary_min__c
    alias_attribute :base_salary_max, :web_schema_basesalary_max__c
    alias_attribute :base_salary_unit_text, :web_schemaquantitativeunittext__c

    def context
      'https://schema.org/'
    end

    def schema_type
      'JobPosting'
    end

    def date_posted
      object.created_at&.to_date&.iso8601
    end

    def valid_through
      object.web_expiredatetime__c&.iso8601
    end

    def hiring_organization
      {
        '@type' => 'Organization',
        'name' => '株式会社みらいワークス',
        'sameAs' => 'https://www.mirai-works.co.jp/'
      }
    end

    def jobposting_location
      {
        '@type' => 'Place',
        'address' => {
          '@type' => 'PostalAddress',
          'addressRegion' => address_region,
          'addressCountry' => 'Japan'
        }
      }
    end

    def job_location_type?
      object.jobposting_joblocationtype__c
    end

    def applicant_location_requirements
      {
        '@type' => 'Country',
        'name' => '日本'
      }
    end

    def job_location_type
      'TELECOMMUTE'
    end

    def base_salary
      {
        '@type' => 'MonetaryAmount',
        'currency' => 'JPY',
        'value' => {
          '@type' => 'QuantitativeValue',
          'minValue' => base_salary_min,
          'maxValue' => base_salary_max,
          'unitText' => base_salary_unit_text
        }
      }
    end
  end
end
