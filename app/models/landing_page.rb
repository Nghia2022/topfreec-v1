# frozen_string_literal: true

class LandingPage < ActiveYaml::Base
  set_root_path Rails.root.join('db/fixtures')
  set_filename 'landing_pages'

  def to_param
    name
  end

  def to_sf_lead_hash
    {
      lp_code__c:          lp_code,
      PMO_Touroku__c:      pmpmo,
      Fintech_Toroku_c__c: fintech
    }
  end
end
