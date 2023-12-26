# frozen_string_literal: true

require 'capybara/rspec'

module ViewportHelper
  def resize_browser_size_to(width = 1024, height = 1024)
    Capybara.current_session.driver.browser.manage.window.resize_to width, height
  end

  def resize_browser_size_to_pc
    resize_browser_size_to(1024, 1024)
  end

  def resize_browser_size_to_sp
    resize_browser_size_to(480, 1024)
  end

  def save_image
    metadata = self.class.metadata
    if metadata[:js] && metadata[:screenshot] == :full
      width, height  = Capybara.page.execute_script('return [Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth), Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)];')
      resize_browser_size_to(width, height)
    end

    super
  end
end

module AjaxHelper
  def wait_for_ajax_finished(wait_time = Capybara.default_max_wait_time)
    Timeout.timeout(wait_time) do
      loop until finished_all_ajax_requests?
    end
    sleep 1
    yield if block_given?
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

module SessionHelper
  def in_browser(name)
    old_session = Capybara.session_name
    Capybara.session_name = name
    yield
    Capybara.session_name = old_session
  end
end

RSpec.configure do |config|
  config.before(:each) do
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
  end

  config.before(:each, type: :system) do |example|
    if example.metadata[:js]
      selenium_requests = %r{/((__.+__)|(hub/session.*))$}
      allow_list = [
        selenium_requests,
        Capybara.server_host
      ]

      if ENV.key? 'SELENIUM_DRIVER_URL'
        driven_by :remote_chrome
        Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
        Capybara.app_host = "http://#{Capybara.server_host}"

        allow_list << ENV.fetch('SELENIUM_DRIVER_URL', nil)
      else
        driven_by :selenium_chrome_headless

        allow_list << 'chromedriver.storage.googleapis.com'
      end
      WebMock.disable_net_connect! allow: allow_list

      host = Capybara.current_session.server.host
      port = Capybara.current_session.server.port
      Rails.application.routes.default_url_options[:host] = "#{host}:#{port}"
    else
      driven_by :rack_test
      Capybara.server_host = '127.0.0.1'
      Capybara.app_host = 'http://www.example.com'
      Rails.application.routes.default_url_options[:host] = 'www.example.com'
    end
  end

  config.include ViewportHelper, type: :system, js: true
  config.include AjaxHelper, type: :system, js: true
  config.include SessionHelper, type: :system
end

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--no-sandbox')
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1680,2200')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.register_driver :remote_chrome do |app|
  url = ENV.fetch('SELENIUM_DRIVER_URL', nil)
  caps = Selenium::WebDriver::Options.chrome(
    'goog:chromeOptions' => {
      'args' => [
        'no-sandbox',
        'headless',
        'disable-gpu',
        'window-size=1680,2200'
      ]
    }
  )
  Capybara::Selenium::Driver.new(app, browser: :remote, url:, capabilities: caps)
end

Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }
Capybara.server_port = 3001

Capybara.add_selector(:testid) do
  css do |val|
    %([data-testid="#{val}"])
  end
end

Capybara.modify_selector(:link) do |selector|
  selector.filter(:method) { |node, method| node[:'data-method'] == method.to_s.downcase }
  selector.filter(:target) { |node, target| node[:target] == target }
  selector.filter(:testid) { |node, testid| node[:'data-testid'] == testid }
end
