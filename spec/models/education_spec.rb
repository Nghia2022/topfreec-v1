# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Education, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: educations
#
#  contact_sfid :string
#  degree       :string
#  degree_name  :string
#  department   :string
#  joined       :string
#  left         :string
#  major        :string
#  school_name  :string
#  school_type  :string
#  sfid         :string           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_educations_on_contact_sfid  (contact_sfid)
#
