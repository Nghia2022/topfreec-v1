# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Salesforce::Picklists::Reloads', type: :request do
  subject do
    send_request
    response
  end

  before do
    inject_session(oauth_email: 'test@ruffnote.com')
  end

  describe 'GET /fcweb-admin-01/salesforce/picklists/reload' do
    it do
      is_expected.to have_http_status(:ok)
    end
  end

  describe 'PUT /fcweb-admin-01/salesforce/picklists/reload' do
    shared_examples 'enqueue job' do
      it do
        expect do
          subject
        end.to have_enqueued_job(Salesforce::Picklists::ReloadJob)
      end
    end

    context 'when reload all picklists' do
      let(:params) do
        {
          reload: {
            sobject_name: ''
          }
        }
      end

      it do
        is_expected.to redirect_to(admin_salesforce_picklists_reload_path)
          .and(satisfy { flash[:notice] == '選択リストマスタの更新を開始しました' })
      end

      it_behaves_like 'enqueue job'
    end

    context 'when reload specified picklist' do
      context 'when sobject_name is valid' do
        let(:params) do
          {
            reload: {
              sobject_name: 'Contact'
            }
          }
        end

        it do
          is_expected.to redirect_to(admin_salesforce_picklists_reload_path)
            .and(satisfy { flash[:notice] == '選択リストマスタの更新を開始しました' })
        end

        it_behaves_like 'enqueue job'
      end

      context 'when sobject_name is valid' do
        let(:params) do
          {
            reload: {
              sobject_name: 'NotExist'
            }
          }
        end

        it do
          is_expected.to redirect_to(admin_salesforce_picklists_reload_path)
            .and(satisfy { flash[:alert].present? })
        end

        it do
          expect do
            subject
          end.not_to have_enqueued_job
        end
      end
    end
  end
end
