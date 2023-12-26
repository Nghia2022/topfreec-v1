# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Fc::Directions::Rejects', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let!(:fc_user) { FactoryBot.create(:fc_user, :activated) }
  let(:account) { fc_user.account }
  let(:contact) { fc_user.contact }
  let(:sf_account_fc) { FactoryBot.build(:sf_account_fc) }
  let(:sf_contact) { FactoryBot.build(:sf_contact) }

  describe 'GET /mypage/fc/directions/:id/reject' do
    let(:id) { direction.id }
    let(:project) { FactoryBot.create(:project, :with_client, fc_account: account, main_fc_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_fc, project:) }

    before do
      sign_in(fc_user)
    end

    it { is_expected.to have_http_status(:ok) }
  end

  describe 'POST /mypage/fc/directions/:id/reject' do
    let(:id) { direction.id }
    let(:project) { FactoryBot.create(:project, :with_client, fc_account: account, main_fc_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_fc, project:) }

    before do
      stub_salesforce_create_request('Task', anything)
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(fc_user)
    end

    context 'with valid params' do
      let(:params) { { direction: { comment_from_fc: 'comment' } } }

      it do
        is_expected.to redirect_to(mypage_fc_directions_path)
      end

      it do
        expect do
          send_request
          direction.reload
        end.to change(direction, :status__c).from('waiting_for_fc').to('rejected')
          .and change(direction, :commentfromfc__c).from(nil).to(params[:direction][:comment_from_fc])
      end
    end

    context 'with invalid params' do
      let(:params) { { direction: { comment_from_fc: '' } } }

      it do
        is_expected.to have_http_status(:unprocessable_entity)
      end

      it do
        expect(response_body).to have_content('修正申請の理由を入力してください')
      end

      it do
        expect do
          send_request
          direction.reload
        end.not_to change(direction, :status__c)
      end
    end

    context 'when request failed' do
      context 'when restforce raise error' do
        let(:params) { { direction: { comment_from_fc: 'comment' } } }

        before do
          allow_any_instance_of(Tasks::CreateService).to receive(:call).and_raise(Restforce::ResponseError, 'error')
        end

        it do
          expect do
            send_request
            direction.reload
          end.to raise_error(StandardError)
            .and not_change(direction, :status__c)
        end
      end
    end
  end
end
