module Pro
  class ReviewsController < BaseController
    before_action :require_professional!

    def index
      @reviews = @professional.reviews
                   .includes(:client, booking: :service)
                   .recent

      @rating_avg = @professional.rating_avg
      @rating_count = @professional.rating_count
      @star_distribution = @professional.reviews.group(:rating).count
    end

    def reply
      @review = @professional.reviews.find(params[:id])

      if @review.pro_reply.present?
        redirect_to pro_reviews_path, alert: "Ya respondiste esta reseña"
        return
      end

      if @review.update(pro_reply: params[:review][:pro_reply], pro_replied_at: Time.current)
        redirect_to pro_reviews_path, notice: "Respuesta enviada"
      else
        redirect_to pro_reviews_path, alert: @review.errors.full_messages.join(", ")
      end
    end
  end
end
