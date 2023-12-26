# frozen_string_literal: true

require 'action_view/template'

module App
  class Template
    module Handlers
      class ERB < ActionView::Template::Handlers::ERB
        def call(template, source)
          source.gsub!(%r{(?<tag><img.+)src="images/}, '\k<tag>src="/images/')
          super
        end
      end
    end
  end
end

ActionView::Template.register_template_handler :erb, App::Template::Handlers::ERB.new

module Cell
  module Erb
    module TemplateFilter
      def precompiled_template(_locals)
        # TODO: Temple::Filterでの実装にしたい(コンパイル結果をキャッシュできる)
        data.gsub!(%r{(?<tag><img.+)src="images/}, '\k<tag>src="/images/')
        super(data)
      end
    end
  end
end

Cell::Erb::Template.prepend Cell::Erb::TemplateFilter
