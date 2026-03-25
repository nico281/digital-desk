require "test_helper"

class Pro::ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pro_user = users(:pro_user)
    @client = users(:client)
    @review = reviews(:good_review)
  end

  # --- Index ---

  test "requires authentication" do
    get pro_reviews_path
    assert_redirected_to new_user_session_path
  end

  test "requires professional" do
    sign_in @client
    get pro_reviews_path
    assert_redirected_to pro_setup_path
  end

  test "pro can see reviews index" do
    sign_in @pro_user
    get pro_reviews_path
    assert_response :success
    assert_select "h1", /Mis reseñas/
  end

  test "index shows review data" do
    sign_in @pro_user
    get pro_reviews_path
    assert_response :success
    assert_match @review.comment, response.body
    assert_match @client.name, response.body
  end

  # --- Reply ---

  test "pro can reply to review" do
    sign_in @pro_user

    patch reply_pro_review_path(@review), params: {
      review: { pro_reply: "Gracias por tu reseña!" }
    }

    assert_redirected_to pro_reviews_path
    @review.reload
    assert_equal "Gracias por tu reseña!", @review.pro_reply
    assert_not_nil @review.pro_replied_at
  end

  test "cannot reply twice" do
    @review.update_columns(pro_reply: "Ya respondí", pro_replied_at: Time.current)
    sign_in @pro_user

    patch reply_pro_review_path(@review), params: {
      review: { pro_reply: "Otra respuesta" }
    }

    assert_redirected_to pro_reviews_path
    assert_equal "Ya respondí", @review.reload.pro_reply
  end

  test "reply too long fails" do
    sign_in @pro_user

    patch reply_pro_review_path(@review), params: {
      review: { pro_reply: "x" * 1001 }
    }

    assert_redirected_to pro_reviews_path
    assert_nil @review.reload.pro_reply
  end

  test "client cannot access pro reviews" do
    sign_in @client
    get pro_reviews_path
    assert_redirected_to pro_setup_path
  end

  test "client cannot reply to reviews" do
    sign_in @client
    patch reply_pro_review_path(@review), params: {
      review: { pro_reply: "No debería poder" }
    }
    assert_redirected_to pro_setup_path
  end
end
