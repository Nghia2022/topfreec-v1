# frozen_string_literal: true

shared_context 'erb' do
  before do
    res = { view_handler: :erb }
    def res.id
      SecureRandom.hex(16)
    end
    inject_session(res)
  end
end

shared_context 'slim' do
  before do
    res = { view_handler: :slim }
    def res.id
      SecureRandom.hex(16)
    end
    inject_session(res)
  end
end

RSpec.configure do |config|
  config.include_context 'erb', :erb
  config.include_context 'slim', :slim
end
