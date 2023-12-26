# frozen_string_literal: true

module ResponseJson
  refine ActionDispatch::TestResponse do
    def json
      JSON.parse(body)
    end
  end
end
