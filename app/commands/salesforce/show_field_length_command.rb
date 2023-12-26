# frozen_string_literal: true

# :nocov:
class Salesforce::ShowFieldLengthCommand
  include Service

  def initialize(sobject_name, form_name)
    self.sobject = sobject_name.constantize
    self.form = form_name.constantize
  end

  private

  attr_accessor :sobject, :form

  def call
    form.attribute_aliases.each do |aliased, origin|
      field = sobject.cached_describe_field(origin)
      length = field[:length]
      next if length.zero?

      puts "validates :#{aliased}, length: { maximum: #{length} }" # rubocop:disable Rails/Output
    end
  end
end
# :nocov:
