# frozen_string_literal: true

RSpec.shared_examples 'pagerizer' do
  let(:account) { FactoryBot.build_stubbed(:sf_account_fc) }
  let(:scoped_columns) do
    model.published.limit(per_page * 2).order(post_date: :desc)
  end
  let(:per_page) { 15 }

  before do
    allow(model).to receive(:latest_order).and_return(scoped_columns)

    allow_any_instance_of(Account).to receive(:to_sobject).and_return(account)
  end

  it do
    visit contents_url

    expect(page).to have_link(class: 'next page-numbers', href: "#{contents_path}?page=2")
      .and have_selector(:testid, "content/#{content_name}/show", count: per_page)
  end

  context 'when click next link' do
    it do
      visit contents_url

      expect(page.current_url).to eq(contents_url)

      click_link(class: 'next page-numbers')

      expect(page.current_url).to eq("#{contents_url}?page=2")
    end
  end
end
