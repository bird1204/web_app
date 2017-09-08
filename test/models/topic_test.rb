require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "get all topic" do
    topics = Topic.all
    assert topics.size > 0
  end

end
