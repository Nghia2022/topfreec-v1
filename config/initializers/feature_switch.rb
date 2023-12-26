# frozen_string_literal: true

Rails.application.config.after_initialize do
  next if Rails.env.test?
  next if Flipper.instance.adapter.adapter.is_a?(Flipper::Adapters::ActiveRecord) &&
          !Flipper::Adapters::ActiveRecord::Feature.table_exists?

  # Known features
  FeatureSwitch.add :new_work_category,
                    description: 'スキルタグ'
  FeatureSwitch.add :new_project_category_meta,
                    description: '#3351 /projects/:slug での一覧表示'
  FeatureSwitch.add :new_ideco,
                    description: '野村證券のiDeCoのURLの切り替え'
end
