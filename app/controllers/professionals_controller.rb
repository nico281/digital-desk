class ProfessionalsController < ApplicationController
  def show
    @professional = Professional.find(params[:id])
    @services = @professional.services.active
    @reviews = @professional.reviews.order(created_at: :desc).limit(5)
  end

  def slots
    @professional = Professional.find(params[:id])
    @service = @professional.services.find(params[:service_id])
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.tomorrow
    @date = [ @date, Date.today ].max

    @blocks = @professional.availability_blocks
      .available
      .for_date(@date)
      .order(:start_time)

    render layout: false
  end
end
