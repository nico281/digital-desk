require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @review = reviews(:good_review)
    @completed_booking = bookings(:completed_booking)
    @pending_booking = bookings(:pending_booking)
    @client = users(:client)
    @other_client = users(:other_client)
    @pro = professionals(:pro)
  end

  # --- Validations ---

  test "valid review" do
    assert_valid @review
  end

  test "rating required" do
    @review.rating = nil
    assert_invalid @review
  end

  test "rating must be 1-5" do
    [ 0, 6, -1, 100 ].each do |bad_rating|
      @review.rating = bad_rating
      assert_invalid @review
    end

    (1..5).each do |good_rating|
      @review.rating = good_rating
      assert_valid @review
    end
  end

  test "comment max 1000 chars" do
    @review.comment = "x" * 1001
    assert_invalid @review
  end

  test "comment within limit is valid" do
    @review.comment = "x" * 1000
    assert_valid @review
  end

  test "pro_reply max 1000 chars" do
    @review.pro_reply = "x" * 1001
    assert_invalid @review
  end

  test "pro_reply within limit is valid" do
    @review.pro_reply = "x" * 1000
    assert_valid @review
  end

  test "one review per booking" do
    duplicate = Review.new(
      booking: @completed_booking,
      client: @client,
      professional: @pro,
      rating: 3
    )
    assert_invalid duplicate
  end

  test "booking must be completed" do
    review = Review.new(
      booking: @pending_booking,
      client: @client,
      professional: @pro,
      rating: 4
    )
    assert_invalid review
  end

  test "client must be booking client" do
    review = Review.new(
      booking: @completed_booking,
      client: @other_client,
      professional: @pro,
      rating: 4
    )
    assert_invalid review
  end

  # --- Scopes ---

  test "replied scope" do
    @review.update_columns(pro_reply: "Gracias!", pro_replied_at: Time.current)
    assert_includes Review.replied, @review
    assert_not_includes Review.unreplied, @review
  end

  test "unreplied scope" do
    assert_includes Review.unreplied, @review
    assert_not_includes Review.replied, @review
  end

  # --- Rating update ---

  test "creating review updates professional rating" do
    @pro.update_columns(rating_avg: 0.0, rating_count: 0)
    # Delete existing review to test fresh
    @review.delete

    new_booking = Booking.create!(
      client: @client,
      professional: @pro,
      service: services(:yoga_class),
      availability_block: availability_blocks(:completed_block),
      status: :completed
    )

    Review.create!(
      booking: new_booking,
      client: @client,
      professional: @pro,
      rating: 4
    )

    @pro.reload
    assert_equal 4.0, @pro.rating_avg
    assert_equal 1, @pro.rating_count
  end
end
