# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Projects::ExperienceCategoryDecorator do
  subject(:decorated) { described_class.decorate(model) }
  let(:model) { Project::ExperienceCategory.first }

  describe '#cloudinary_folder' do
    subject { decorated.cloudinary_folder }

    it do
      is_expected.to eq "categories/#{model.slug}"
    end
  end
end
