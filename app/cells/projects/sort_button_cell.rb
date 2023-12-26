# frozen_string_literal: true

# disable :reek:InstanceVariableAssumption
class Projects::SortButtonCell < ApplicationCell
  def show(options = { path: :projects_path })
    @path = options[:path]
    render
  end

  # disable :reek:DuplicateMethodCall
  def link_class(type)
    class_names(
      'btn', 'bs-small',
      'btn-theme-02-outline': sort_type != type.to_s,
      'btn-theme-02':         sort_type == type.to_s
    )
  end

  def projects_path_sort_by(type)
    public_send(path, options[:search_params].except(:page).merge(sort: type))
  end

  private

  def path
    @path.presence || :projects_path
  end

  def sort_type
    options[:search_params].fetch(:sort, 'createddate')
  end
end
