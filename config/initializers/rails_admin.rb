# frozen_string_literal: true

require './lib/rails_admin_project_sub_category_select'

RailsAdmin.config do |config|
  config.asset_source = :sprockets
  config.parent_controller = 'ApplicationController'

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.excluded_models += %w[
    Fc::UserActivation::FcUser
    Fc::UserRegistration::FcUser
    Client::UserRegistration::ClientUser
    MatchingBase
    Opportunity
  ]

  config.model 'ProjectCategoryMetum' do
    create do
      configure :slug do
        read_only false
      end
      configure :work_category do
        inline_add false
        inline_edit false
      end
      configure :work_category_sub, :project_sub_category_select
    end

    edit do
      configure :slug do
        read_only true
      end
      configure :work_category do
        inline_add false
        inline_edit false
        read_only true
      end
      configure :work_category_sub, :project_sub_category_select do
        read_only true
      end
    end
  end
end
