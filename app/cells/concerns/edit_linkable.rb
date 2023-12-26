# frozen_string_literal: true

# :nocov:
module EditLinkable
  extend ActiveSupport::Concern

  def edit_link
    link_to '登録・変更', edit_link_path, edit_link_options if edit_link_path.present?
  end

  def edit_link_path
    options[:edit_link_path]
  end

  def edit_link_options
    opts = options.fetch(:edit_link_options, {})
    opts = opts.deep_merge(modal_options) if edit_modal?
    opts
  end

  def edit_modal?
    options.fetch(:edit_modal, false)
  end

  def modal_options
    {
      class: 'modal-trigger',
      data:  { target: 'modal' }
    }
  end
end
# :nocov:
