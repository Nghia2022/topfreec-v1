# frozen_string_literal: true

class ProfileDecorator < Draper::Decorator
  delegate_all

  def last_name
    object.LastName
  end

  def first_name
    object.FirstName
  end

  def full_name
    [
      last_name,
      first_name
    ].join ' '
  end

  def last_name_kana
    object.Kana_Sei__c.to_s
  end

  def first_name_kana
    object.Kana_Mei__c.to_s
  end

  # :nocov:
  def full_name_kana
    [
      last_name_kana,
      first_name_kana
    ].join ' '
  end
  # :nocov:

  def zipcode
    object.MailingPostalCode
  end

  def prefecture
    object.MailingState
  end

  def city
    object.MailingCity
  end

  def building
    object.MailingStreet
  end

  # FIXME: 固定と携帯の番号の区別がつかないので、項目の定義を確認してメソッド名を変更する
  def phone
    object.Phone
  end

  # FIXME: 固定と携帯の番号の区別がつかないので、項目の定義を確認してメソッド名を変更する
  def phone2
    object.HomePhone
  end

  def email
    object.Email
  end

  def web_login_email
    object.Web_LoginEmail__c
  end

  private

  # :nocov:
  def pending
    '項目未確認'
  end
  # :nocov:
end
