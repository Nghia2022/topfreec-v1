# frozen_string_literal: true

module Fc::MainRegistration
  class Profile
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :MailingState, :string
    attribute :MailingCity, :string
    attribute :MailingStreet, :string
    attribute :MailingPostalCode, :string

    alias_attribute :prefecture, :MailingState
    alias_attribute :city, :MailingCity
    alias_attribute :building, :MailingStreet
    alias_attribute :zipcode, :MailingPostalCode

    def initialize(attrs = {})
      @persisted = false
      super
    end

    def save(contact)
      if valid?
        # TODO: エラー処理
        self.persisted = restforce.update!(contact.sobject_name, { Id: contact.sfid }.merge(serializable_hash))
      else
        # :nocov:
        false
        # :nocov:
      end
    end

    def serializable_hash
      attributes
    end

    def aliase_attributes
      attribute_aliases.keys.index_with do |key|
        public_send(key)
      end
    end

    # :nocov:
    def persisted?
      persisted
    end
    # :nocov:

    class << self
      def new_from_sobject(sobject)
        new(sobject.slice(*attribute_names).to_h)
      end
    end

    private

    attr_writer :persisted

    # :nocov:
    def persisted
      @persisted ||= false
    end
    # :nocov:

    def restforce
      @restforce ||= RestforceFactory.new_client
    end
  end
end
