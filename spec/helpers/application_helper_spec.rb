# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  include described_class

  describe '#auto_paragraph' do
    let(:text) do
      <<~WPTEXT
        今回お話を伺ったのは、日本を代表する大手製薬メーカーA社でIT部門のチームリーダーを務めるX氏。

        <!--more-->
        独立して活動するフリーランスの皆さんを

        &nbsp;

        <h2>「そんな人いません」と言わないみらいワークスの強み</h2>
      WPTEXT
    end

    it do
      expect(auto_paragraph(text)).to eq <<~EXPECT.rstrip
        <p>今回お話を伺ったのは、日本を代表する大手製薬メーカーA社でIT部門のチームリーダーを務めるX氏。</p>
        <p>&nbsp;</p>
        <p>独立して活動するフリーランスの皆さんを</p>
        <p>&nbsp;</p>
        <h2>「そんな人いません」と言わないみらいワークスの強み</h2>
      EXPECT
    end
  end

  describe '#active_menu' do
    let(:request) { instance_double('request', path_info:) }
    let(:path_info) { '/welcome' }

    it { expect(active_menu('/welcome')).to eq 'active' }
    it { expect(active_menu('/welcome/')).to eq 'active' }
    it { expect(active_menu('/about')).to be_nil }
    it { expect(active_menu('/welcome', '/about')).to eq 'active' }

    context '似た名前のとき' do
      let(:path_info) { '/welcome_page' }
      it { expect(active_menu('/welcome')).to be_nil }
    end

    context '指定したページよりも深い階層にいる場合' do
      let(:path_info) { '/welcome/about' }
      it { expect(active_menu('/welcome')).to eq 'active' }
      it { expect(active_menu('/about')).to be_nil }
    end

    context 'with active_class' do
      it { expect(active_menu('/welcome', active_class: 'c-red')).to eq 'c-red' }
    end
  end

  describe '#merge_url_for' do
    let(:request) { instance_double('request', original_url:, params:) }

    context 'when new query' do
      let(:original_url) { 'http://example.com/foo' }
      let(:params) do
        {}
      end

      it do
        expect(merge_url_for(view_handler: :erb)).to eq 'http://example.com/foo?view_handler=erb'
      end
    end

    context 'when override existing query' do
      let(:original_url) { 'http://example.com/foo?view_handler=slim' }
      let(:params) do
        {}
      end

      it do
        expect(merge_url_for(view_handler: :erb)).to eq 'http://example.com/foo?view_handler=erb'
      end
    end
  end
end
