# frozen_string_literal: true

# :reek:MissingSafeMethod { exclude: [ arrange_work_categories! ] }
class Fc::Settings::DesiredWorkCategoryForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveRecord::AttributeMethods::BeforeTypeCast
  extend Fc::Settings::ContactAttributable

  # Contact attributes
  attribute :desired_works_main, array: :string
  attribute :desired_works_sub, array: :string

  # Contact attributes
  alias_attribute :desired_works_main__c, :desired_works_main
  alias_attribute :desired_works_sub__c, :desired_works_sub

  validates :desired_works_sub,
            length:    { maximum: 100 },
            inclusion: {
              in: ->(_) { WorkCategory.pluck(:sub_category).flatten }
            }

  def save(contact)
    arrange_work_categories!

    return false if invalid?

    begin
      contact.assign_attributes(contact_attributes)
      contact.save!
    ensure
      errors.merge!(contact.errors)
    end
  end

  private

  def arrange_work_categories!
    desired_works_sub&.reject!(&:blank?)
    assign_attributes({ desired_works_main: grouped_desired_works_main })
  end

  def contact_attributes
    {
      desired_works_main__c: desired_works_main,
      desired_works_sub__c:  desired_works_sub
    }
  end

  def grouped_desired_works_main
    WorkCategory.group_sub_categories(desired_works_sub).keys
  end
end
