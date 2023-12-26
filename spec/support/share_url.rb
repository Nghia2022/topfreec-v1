# frozen_string_literal: true

shared_examples_for 'share_url' do |url|
  describe '#facebook_share_url' do
    it do
      expect(subject.facebook_share_url).to eq "http://www.facebook.com/share.php?u=#{url}"
    end
  end

  describe '#twitter_share_url' do
    it do
      expect(subject.twitter_share_url).to eq "https://twitter.com/share?url=#{url}"
    end
  end

  describe '#hatena_share_url' do
    it do
      expect(subject.hatena_share_url).to eq "http://b.hatena.ne.jp/add?mode=confirm&url=#{url}"
    end
  end
end
