# frozen_string_literal: true

class Direction::CollectionDecorator < PaginatingDecorator
  delegate :open_unread
end
