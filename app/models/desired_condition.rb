# frozen_string_literal: true

class DesiredCondition
  include ActiveModel::Model
  include ActiveModel::Naming
  extend Enumerize

  WORK_AREAS = {
    kanto:      '関東（一都三県）',
    kita_kanto: '関東（一都三県以外）',
    kinki:      '近畿',
    domestic:   'その他（国内）',
    overseas:   'その他（海外）'
  }.freeze
  WORK_LOCATIONS = %i[hokkaido kita_kanto tokyo_23wards tokyo_others capital_area chubu kinki chugoku shikoku kyushu japan overseas].freeze
  NO_PARTICIPATE_COMPANY_NAMES_MAXIMUM = 1200

  enumerize :company_sizes, in: { major: '大手', sme: '中小', venture: 'ベンチャー', startup: 'スタートアップ' }, multiple: true
  enumerize :work_area, in: WORK_AREAS, i18n_scope: 'enumerize.desired_condition.work_area'
  enumerize :work_location1, in: WORK_LOCATIONS, i18n_scope: 'enumerize.desired_condition.work_location'
  enumerize :work_location2, in: WORK_LOCATIONS, i18n_scope: 'enumerize.desired_condition.work_location'
  enumerize :work_location3, in: WORK_LOCATIONS, i18n_scope: 'enumerize.desired_condition.work_location'

  class << self
    def experienced_works_options
      Contact::ExperiencedWork.all.map { |item| [item.value] }
    end

    def desired_works_options
      Contact::DesiredWork.all.map { |item| [item.value] }
    end

    def company_sizes_options
      DesiredCondition.company_sizes.options
    end

    def occupancy_rate_options
      [
        ['週5日', 100],
        ['週4日', 80],
        ['週3日', 60],
        ['週2日', 40],
        ['週1日', 20]
      ]
    end

    def work_area_options
      work_area.values.map(&:text)
    end

    def work_location_options
      Contact::WorkPrefecture1.all.map { |item| [item.value] }
    end

    def business_form_options
      Contact::WorkOption.all.map { |item| [item.value] }
    end
  end
end
