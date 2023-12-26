# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WordpressImageReplacer, type: :lib do
  describe '.replace' do
    subject { WordpressImageReplacer.replace(source) }

    context 'URL' do
      let(:source) { 'https://freeconsultant.jp/wp-content/uploads/2020/10/example.jpg' }

      it { is_expected.to eq('https://file.freeconsultant.jp/wp-content/uploads/2020/10/example.jpg') }
    end

    context 'HTML' do
      let(:source) { '<a href="https://freeconsultant.jp/"><img src="https://freeconsultant.jp/wp-content/uploads/2020/10/example.jpg"></a>' }

      it { is_expected.to eq('<a href="https://freeconsultant.jp/"><img src="https://file.freeconsultant.jp/wp-content/uploads/2020/10/example.jpg"></a>') }
    end
  end
end
