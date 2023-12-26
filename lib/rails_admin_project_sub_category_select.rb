# frozen_string_literal: true

module RailsAdmin
  module Config
    module Fields
      class ProjectSubCategorySelect < Base
        # :nocov:
        # フィールドタイプの登録
        RailsAdmin::Config::Fields::Types.register(:project_sub_category_select, self)

        # モデルに登録されている値から、表示用に整形した値を返す
        # 一覧画面に表示される
        register_instance_option :pretty_value do
          ProjectCategoryMetum.find_by(work_category_sub: value)&.work_category_sub
        end

        # このフィールドが表示するテンプレート
        register_instance_option :partial do
          :form_project_sub_category_select
        end

        # ビューから参照するために自分で定義したメソッド
        def method_name
          :work_category_sub
        end
        # :nocov:
      end
    end
  end
end
