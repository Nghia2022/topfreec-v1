# frozen_string_literal: true

namespace :migration do
  namespace :cloudinary do
    task convert_to_category: :environment do
      Project::ExperienceCategory.all.find_each do |category|
        (1..4).each do |index|
          original_url = ApplicationController.helpers.cl_image_path("occupations/#{category.slug}/#{index}.jpg")
          Cloudinary::Uploader.upload(original_url, public_id: "categories/#{category.slug}/#{index}")
        rescue CloudinaryException
          # skip
        end
      end
    end
  end
end
