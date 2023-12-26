# frozen_string_literal: true

shared_examples_for 'redirect with status moved permanently' do
  it do
    is_expected.to redirect_to("#{path}/")
      .and have_http_status(:moved_permanently)
  end
end
