require "test_helper"

class ProfessionalTest < ActiveSupport::TestCase
  setup do
    @pro = professionals(:pro)
  end

  test "update_rating! calculates correctly" do
    @pro.update_columns(rating_avg: 0.0, rating_count: 0)

    @pro.update_rating!(5)
    assert_equal 5.0, @pro.rating_avg
    assert_equal 1, @pro.rating_count

    @pro.update_rating!(3)
    assert_equal 4.0, @pro.rating_avg
    assert_equal 2, @pro.rating_count

    @pro.update_rating!(1)
    assert_equal 3.0, @pro.rating_avg
    assert_equal 3, @pro.rating_count
  end

  test "rating_avg must be 0-5" do
    @pro.rating_avg = -1
    assert_not @pro.valid?

    @pro.rating_avg = 6
    assert_not @pro.valid?

    @pro.rating_avg = 4.5
    assert @pro.valid?
  end
end
