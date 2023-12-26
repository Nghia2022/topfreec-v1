# frozen_string_literal: true

class HeaderCell < ApplicationCell
  def show
    name = partial_name_for_show
    render(name) if name
  end

  private

  def action_from_options
    options.fetch(:action, nil)
  end

  # :reek:NilCheck
  # :nocov:
  PARTIAL_NAME_ROUTER = [
    [
      -> { action_from_options.present? },
      -> { action_from_options }
    ],
    [
      -> { model.nil? },
      -> { :show }
    ],
    [
      -> { model.fc? },
      -> { model.registration_completed? ? :fc : :show }
    ],
    [
      -> { model.fc_company? },
      -> { :fc_company }
    ],
    [
      -> { model.client? },
      -> { :client }
    ],
    [
      -> { model.wp_user? },
      -> { :show }
    ]
  ].freeze
  # :nocov:

  def partial_name_for_show
    PARTIAL_NAME_ROUTER.each do |cond, name_generator|
      return instance_exec(&name_generator) if instance_exec(&cond)
    end
    nil
  end
end
