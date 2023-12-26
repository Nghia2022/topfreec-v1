# frozen_string_literal: true

module Fc::Settings::ContactAttributable
  def new_from_contact(contact)
    contact_attributes = contact.attributes.slice(*attribute_alias_keys)

    new({}.merge(contact_attributes))
  end

  private

  def attribute_alias_keys
    attribute_aliases.keys
  end
end
