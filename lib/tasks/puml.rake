# frozen_string_literal: true

class PumlBuilder
  def initialize
    @buffer = StringIO.new
  end

  attr_reader :buffer

  def draw
    buffer.puts '@startuml'
    nl

    yield self

    nl
    buffer.puts '@enduml'

    buffer.rewind && buffer.read
  end

  def uml
    self
  end

  def newline
    buffer << "\n"

    self
  end
  alias nl newline

  def rarrow(from:, to:, label: nil)
    buffer << "#{from} --> #{to}"
    buffer << ": #{label}" if label
    nl
    self
  end

  def text(name, label)
    buffer.puts  "#{name}: #{label}"
    self
  end

  class << self
    def draw(&)
      new.draw(&)
    end
  end
end

module Paml
  class GenerateTask
    def call
      models.each do |model|
        Rails.root.join('tmp/puml', "#{model.model_name.singular}.puml").write(draw_state_machine_puml(model))
      end
    end

    def models
      Rails.application.eager_load!
      ActiveRecord::Base.descendants
                        .select { |c| c.respond_to? :aasm }
                        .reject { |c| c.respond_to?(:extended_record_base_class) }
    end

    # rubocop:disable Metrics/AbcSize
    def draw_state_machine_puml(model)
      PumlBuilder.draw do |uml|
        uml.rarrow from: '[*]', to: model.aasm.initial_state

        model.aasm.states.each do |state|
          uml.text state, state_label(model, state.name)
        end

        uml.nl

        model.aasm.events.each do |event|
          event.transitions.each do |transition|
            uml.rarrow from: transition.from, to: transition.to, label: event.name
          end
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    def state_label(model, name)
      model.public_send(model.aasm.state_machine.config.column.to_s.pluralize)[name]
    end

    class << self
      def call(*)
        new(*).call
      end
    end
  end
end

namespace :puml do
  task generate: :environment do
    Paml::GenerateTask.call
  end
end
