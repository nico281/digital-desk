class ProfessionalsController < ApplicationController
  def show
    @professional = Professional.find(params[:id])
    @services = @professional.services.active
    @reviews = @professional.reviews.includes(:client).order(created_at: :desc).limit(5)
  end

  def slots
    @professional = Professional.find(params[:id])
    @service = @professional.services.find(params[:service_id])
    @date = params[:date].present? ? Date.parse(params[:date]) : Date.tomorrow
    @date = [ @date, Date.today ].max

    lead_hours = @professional.require_confirmation? ? 4 : 1

    @blocks = @professional.availability_blocks
      .available
      .for_date(@date)
      .with_lead_time(lead_hours)
      .order(:start_time)

    render layout: false
  end
end
