# frozen_string_literal: true

class Mypage::Fc::Profiles::HeaderCell < ApplicationCell
  def show
    if model.fc?
      render :fc
    elsif model.fc_company?
      render :fc_company
    end
  end

  def show_sp
    if model.fc?
      render :fc_sp
    elsif model.fc_company?
      render :fc_company_sp
    end
  end

  def menu_fc
    render
  end

  def menu_fc_company
    render
  end
end
