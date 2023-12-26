# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DemuxInterceptor, type: :interceptor do
  describe '#delivering_email' do
    subject { interceptor.delivering_email(mail) }

    let(:interceptor) { DemuxInterceptor.new }
    let(:mail) { Mail::Message.new(from:, to: recipients) }
    let(:from) { Faker::Internet.email }
    let(:valid_email) { Faker::Internet.email }
    let(:invalid_email) { "#{Faker::Internet.email}.invalid" }

    context 'when `To:` includes valid and invalid' do
      let(:recipients) { [valid_email, invalid_email] }

      it do
        expect do
          subject
        end.to change(mail, :to).to([valid_email])
      end
    end

    context 'when `To:` is all valid' do
      let(:recipients) { [valid_email] }

      it do
        expect do
          subject
        end.to not_change(mail, :to).from(recipients)
      end
    end

    context 'when `To:` is all invalid' do
      let(:recipients) { [invalid_email] }

      it do
        expect do
          subject
        end.to change(mail, :to).to([])
          .and change(mail, :perform_deliveries).to(false)
      end
    end

    context 'when `Cc:` includes valid and invalid', :focus do
      let(:mail) { Mail::Message.new(from:, cc: recipients) }
      let(:recipients) { [valid_email, invalid_email] }

      it do
        expect do
          subject
        end.to change(mail, :cc).to([valid_email])
      end
    end

    context 'when `Cc:` is all valid' do
      let(:mail) { Mail::Message.new(from:, cc: recipients) }
      let(:recipients) { [valid_email] }

      it do
        expect do
          subject
        end.to not_change(mail, :cc).from(recipients)
      end
    end

    context 'when `Cc:` is all invalid' do
      let(:mail) { Mail::Message.new(from:, to: valid_email, cc: recipients) }
      let(:recipients) { [invalid_email] }

      it do
        expect do
          subject
        end.to change(mail, :cc).to([])
          .and not_change(mail, :perform_deliveries).from(true)
      end
    end
  end
end
