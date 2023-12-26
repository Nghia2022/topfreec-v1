# frozen_string_literal: true

class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(Rails.root.join("config/routes/#{routes_name}.rb").read)
  end
end

Rails.application.routes.draw do
  namespace :admin do
    namespace :projects do
      get 'experience_categories/index'
    end
  end
  draw :engines
  draw :devise
  draw :api
  draw :mypage
  draw :admin
  draw :cms
  draw :web
  draw :page
  draw :landing_pages
  draw :direct

  get ':folder/:slug', to: 'files#show', constraints: { slug: /.*/ }
end
