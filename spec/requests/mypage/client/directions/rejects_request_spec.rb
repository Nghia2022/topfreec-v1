# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Mypage::Client::Directions::Rejects', type: :request do
  subject do
    send_request
    response
  end

  let(:response_body) { subject.body }

  let!(:client_user) { FactoryBot.create(:client_user, :with_contact) }
  let(:contact) { client_user.contact }
  let(:direction_id) { direction.id }

  describe 'GET /mypage/cl/directions/:direction_id/reject' do
    let(:project) { FactoryBot.create(:project, main_cl_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_client, project:) }

    before do
      sign_in(client_user)
    end

    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'POST /mypage/cl/directions/:direction_id/reject' do
    let(:project) { FactoryBot.create(:project, main_cl_contact: contact) }
    let!(:direction) { FactoryBot.create(:direction, :waiting_for_client, project:) }
    let(:sf_contact) { FactoryBot.build(:sf_contact) }

    before do
      stub_salesforce_create_request('Task', anything)
      allow_any_instance_of(Contact).to receive(:to_sobject).and_return(sf_contact)
      sign_in(client_user)
    end

    context 'with valid params' do
      let(:params) do
        {
          direction: {
            new_direction_detail: Faker::Lorem.paragraphs(number: rand(3..7)).join("\n")
          }
        }
      end

      it do
        is_expected.to redirect_to(mypage_client_directions_path)
      end

      it do
        expect do
          send_request
          direction.reload
        end.to change { direction.status__c }.from('waiting_for_client').to('rejected')
          .and change { direction.newdirectiondetail__c }.from(nil).to(params[:direction][:new_direction_detail])
      end
    end

    context 'with invalid params' do
      let(:params) { { direction: { new_direction_detail: '' } } }

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
        let(:params) { { direction: { new_direction_detail: 'comment' } } }

        before do
          allow_any_instance_of(Tasks::CreateService).to receive(:call).and_raise(Restforce::ResponseError, 'error')
        end

        it do
          expect do
            send_request
          end.to raise_error(StandardError)
            .and not_change(direction.reload, :status__c)
        end
      end
    end
  end
end
