require 'test_helper'

class ClassificationTest < ActiveSupport::TestCase
  test "get all classifications" do
    classifications = Classification.all
    assert classifications.size > 0
  end
end


