# frozen_string_literal: true

class Compensation < ActiveYaml::Base
  set_root_path Rails.root.join('db/fixtures')
  set_filename 'compensations'

  def as_range
    min..max
  end
end
