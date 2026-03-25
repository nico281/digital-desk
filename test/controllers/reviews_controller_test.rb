require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @client = users(:client)
    @completed_booking = bookings(:completed_booking)
    @pending_booking = bookings(:pending_booking)
    @review = reviews(:good_review)
  end

  test "requires authentication" do
    post booking_review_path(@completed_booking), params: { review: { rating: 5 } }
    assert_redirected_to new_user_session_path
  end

  test "create review on completed booking" do
    sign_in @client
    @review.delete # remove fixture so we can create fresh

    assert_difference "Review.count", 1 do
      post booking_review_path(@completed_booking), params: {
        review: { rating: 4, comment: "Muy buena sesión" }
      }
    end
    assert_redirected_to booking_path(@completed_booking)
  end

  test "cannot review pending booking" do
    sign_in @client

    assert_no_difference "Review.count" do
      post booking_review_path(@pending_booking), params: {
        review: { rating: 5 }
      }
    end
  end

  test "cannot review twice" do
    sign_in @client

    assert_no_difference "Review.count" do
      post booking_review_path(@completed_booking), params: {
        review: { rating: 3 }
      }
    end
  end

  test "wrong client cannot review" do
    sign_in users(:other_client)

    @review.delete

    assert_no_difference "Review.count" do
      post booking_review_path(@completed_booking), params: {
        review: { rating: 5 }
      }
    end
  end
end
