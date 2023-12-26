# frozen_string_literal: true

module Breadcrumbs
  class CustomBuilder < BreadcrumbsOnRails::Breadcrumbs::SimpleBuilder
    def render
      @elements.each { |element| element.path = compute_path(element) }
      @context.render 'breadcrumbs', elements: @elements
    end
  end
end
