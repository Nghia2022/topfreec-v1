# frozen_string_literal: true

module FormatMixins
  private

  def join_wave_dash(array, postfix = '')
    array.map { |val| "#{val}#{postfix}" }.join(' 〜 ')
  end
end
