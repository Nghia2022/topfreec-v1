# frozen_string_literal: true

# :reek:TooManyMethods
module Projects
  class SearchForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::AttributeAssignment
    extend Enumerize

    attribute_method_suffix '?'

    attribute :keyword, :string
    attribute :compensation_ids, array: :integer
    attribute :categories, array: :string
    attribute :work_locations, array: :string
    attribute :work_options, array: :string
    attribute :sort, :string
    attribute :occupancy_rate_mins, array: :string
    attribute :occupancy_rate_maxs, array: :string
    attribute :period_from, :string
    attribute :period_to, :string
    attribute :recruiting, :boolean
    attribute :slug, :string

    enumerize :sort, in: %i[compensation createddate], predicates: { prefix: :sort }

    def compensations
      @compensations ||= Compensation.where(id: compensation_ids)
    end

    def compensation_ranges
      compensations.map(&:as_range)
    end

    def category_metum
      # TODO: #3440 FeatureSwitchの分岐を無くしてProject::CategoryMetumを削除する
      @category_metum ||= if FeatureSwitch.enabled?(:new_project_category_meta)
                            ProjectCategoryMetum.fetch_by_or_null(category_metum_params).tap { |item| assign_categories(item.work_category_main) }
                          else
                            Project::CategoryMetum.find_or_null(trimed_categories&.first)
                          end
    end

    def meta_title
      if keyword?
        keyword_for_result
      else
        category_metum.title
      end
    end

    def filter?
      [
        keyword?,
        compensation_ids?,
        categories?,
        work_locations?,
        work_options?,
        occupancy_rate_mins?,
        occupancy_rate_maxs?,
        period_from?,
        period_to?,
        slug?
      ].any?
    end

    def keyword_for_result
      "#{joined_keyword} のコンサル案件・人材募集"
    end

    def canonical?
      # TODO: #3440 FeatureSwitchを削除する
      FeatureSwitch.enabled?(:new_project_category_meta) && trimed_categories&.one?
    end

    class << self
      def permitted_attributes
        %i[keyword sort period_from period_to recruiting slug] +
          [compensation_ids: [], categories: [], work_locations: [], work_options: [], occupancy_rate_mins: [], occupancy_rate_maxs: []]
      end
    end

    private

    def joined_keyword
      keyword.to_s.split.join(',')
    end

    def attribute?(name)
      public_send(name).present?
    end

    def category_metum_params
      slug.present? ? { slug: } : { work_category_main: trimed_categories&.first }
    end

    def assign_categories(value)
      assign_attributes({ categories: [value] }) if slug?
    end

    def trimed_categories
      categories&.reject(&:blank?)
    end
  end
end
