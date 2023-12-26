# frozen_string_literal: true

class Mypage::Fc::Settings::DesiredConditionCell < ApplicationCell
  include EditLinkable

  def show
    render
  end

  # TODO: #3353 showとリプレイス
  def new_show
    render
  end

  # TODO: #3353 削除
  def desired_works
    safe_join(desired_condition.desired_works.to_a, '、'.html_safe + tag.br)
  end

  # TODO: #3353 desired_works に変更
  def desired_new_works
    safe_join(work_category_to_html_by('desired_work_categories'), tag.br)
  end

  # TODO: #3353 削除
  def experienced_works
    safe_join(desired_condition.experienced_works.to_a, '、'.html_safe + tag.br)
  end

  # TODO: #3353 experienced_works に変更
  def experienced_new_works
    safe_join(work_category_to_html_by('experiences_work_categories'), tag.br)
  end

  def company_sizes
    safe_join(desired_condition.company_sizes.to_a, ' / ')
  end

  %i[
    work_location1
    work_location2
    work_location3
  ].each do |method|
    define_method(method) do
      escape_once(desired_condition.public_send(method))
    end
  end

  def business_form
    safe_join(desired_condition.business_form.to_a, '、'.html_safe + tag.br)
  end

  private

  def desired_condition
    @desired_condition ||= Fc::Settings::DesiredConditionForm.new_from_contact(model)
  end

  def work_category_to_html_by(name)
    model.public_send("arranged_#{name}").map do |main_category, sub_categories|
      "#{main_category}: #{sub_categories.join('、')}"
    end
  end
end
