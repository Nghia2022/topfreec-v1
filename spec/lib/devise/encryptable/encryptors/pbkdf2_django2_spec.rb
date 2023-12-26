# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::Encryptable::Encryptors::Pbkdf2Django2, type: :lib do
  using RSpec::Parameterized::TableSyntax

  let(:stretches) { 180_000 }

  before do
    allow(Devise).to receive(:stretches).and_return(stretches)
  end

  where(:plain, :hashed, :salt) do
    'samplesample' | 'pbkdf2_sha256$180000$DgeAa/nTtSFH9svcsJ3DDKgaf/h3d/UWaHRKn15uZWs=' | 'eTsctfOVBCV6'
    '5sDqrENXhtF'  | 'pbkdf2_sha256$180000$cYp5Rw2IFS27bXHgxmZdLT3PilxFyZItiaaap4lOsiQ=' | 'qIGcAVQRka3E'
    'eT)EETLUsyc'  | 'pbkdf2_sha256$180000$/Bh84++HGA9FTq7zH4Xlj6UZo6C0Kf0W7RFyz+QsOtY=' | 'FYZP3bvQSc6O'
  end

  with_them do
    describe '.digest' do
      subject { described_class.digest(plain, stretches, salt, nil) }
      it { is_expected.to eq hashed }
    end

    describe '.compare' do
      context 'with valid password' do
        subject { described_class.compare(hashed, plain, nil, salt, nil) }
        it { is_expected.to eq true }
      end

      context 'with invalid password' do
        subject { described_class.compare(hashed, "#{plain}'invalid", nil, salt, nil) }
        it { is_expected.to eq false }
      end
    end

    describe 'performance' do
      subject { Benchmark.realtime { described_class.digest(plain, stretches, salt, nil) } }
      it { is_expected.to be < 0.3 }
    end
  end
end
