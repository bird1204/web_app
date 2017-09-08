require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  test "get_token" do
    member = Member.login('neo_hsiung@jumplife.com.tw', '12345678')
    assert member.auth_token.present?
  end

  test "name" do
    member = Member.login('neo_hsiung@jumplife.com.tw', '12345678')
    member.name = nil
    assert_equal member.name, 'neo_hsiung'
  end

  test "serialize" do
    m = Member.login('neo_hsiung@jumplife.com.tw', '12345678')

    m2 = Member.new.from_json(m.to_json)

    assert_equal m2.as_json, m.as_json

  end
end

