# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise', type: :config do
  describe 'config' do
    describe '.lock_strategy', :lockable do
      it do
        expect(Devise.lock_strategy).to eq :failed_attempts
      end
    end

    describe '.unlock_strategy', :lockable do
      it do
        expect(Devise.unlock_strategy).to eq :time
      end
    end

    describe '.maximum_attempts', :lockable do
      it do
        expect(Devise.maximum_attempts).to eq 10
      end
    end

    describe '.unlock_in', :lockable do
      it do
        expect(Devise.unlock_in).to eq 30.minutes
      end
    end

    describe '.timeout_in', :timeoutable do
      it do
        expect(Devise.timeout_in).to eq 3.hours
      end
    end

    describe '.password_length', :secure_validatable do
      it do
        expect(Devise.password_length).to eq 8..128
      end
    end
  end
end
