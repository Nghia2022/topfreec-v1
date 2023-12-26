# frozen_string_literal: true

module SalesforceMock
  def stub_salesforce_request
    # stub_request(:any, ENV.fetch('SALESFORCE_HOST'))
    allow_any_instance_of(Restforce::Concerns::API).to receive(:create!).and_return(true)
    allow_any_instance_of(Restforce::Concerns::API).to receive(:update!).and_return(true)
    allow_any_instance_of(Restforce::Concerns::API).to receive(:describe).and_return(true)
  end

  def stub_salesforce_create_request(sobject_name, *)
    allow_any_instance_of(Restforce::Concerns::API).to receive(:create!).with(sobject_name, *).and_return(true)
  end

  def stub_salesforce_update_request(sobject_name, *)
    allow_any_instance_of(Restforce::Concerns::API).to receive(:update!).with(sobject_name, *).and_return(true)
  end
end

RSpec.configure do |config|
  %i[
    model
    job
    request
    feature
    service
    task
    system
  ].each do |type|
    config.include SalesforceMock, type:
  end
end
