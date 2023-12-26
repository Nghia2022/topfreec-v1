# frozen_string_literal: true

Shoulda::Matchers::ActiveModel::ValidationMatcher.include RSpec::Matchers::Composable
Shoulda::Matchers::ActiveModel::ValidateNumericalityOfMatcher.include RSpec::Matchers::Composable
Shoulda::Matchers::ActiveModel::AllowValueMatcher.include RSpec::Matchers::Composable
Shoulda::Matchers::Independent::DelegateMethodMatcher.include RSpec::Matchers::Composable

EmailSpec::Matchers::HaveSubject.include RSpec::Matchers::Composable
EmailSpec::Matchers::HaveBodyText.include RSpec::Matchers::Composable

RSpec::Matchers.define_negated_matcher :not_change, :change
RSpec::Matchers.define_negated_matcher :not_allow_value, :allow_value do |description|
  "not #{description}"
end
RSpec::Matchers.define_negated_matcher :not_allow_values, :allow_values
RSpec::Matchers.define_negated_matcher :not_ending_with, :ending_with
RSpec::Matchers.define_negated_matcher :have_no_enqueued_job, :have_enqueued_job
