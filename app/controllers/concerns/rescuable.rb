# frozen_string_literal: true

module Rescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
    rescue_from ActionController::ParameterMissing, with: :missing_param
    rescue_from StandardError, with: :server_error if Rails.env.production?
  end

  private

  def not_found(exception)
    logger.warn "Record not found: #{exception.message}"

    respond_to do |format|
      format.html { render "errors/not_found", status: :not_found }
      format.json { render json: { error: "Not found" }, status: :not_found }
      format.turbo_stream { render status: :not_found }
    end
  end

  def invalid_record(exception)
    logger.warn "Invalid record: #{exception.message}"

    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :unprocessable_entity }
      format.turbo_stream { render status: :unprocessable_entity }
    end
  end

  def missing_param(exception)
    logger.warn "Missing parameter: #{exception.message}"

    respond_to do |format|
      format.html { redirect_to root_path, alert: "Faltan parámetros requeridos" }
      format.json { render json: { error: "Missing required parameter" }, status: :bad_request }
    end
  end

  def server_error(exception)
    logger.error "Server error: #{exception.class} - #{exception.message}"
    logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html { render "errors/server_error", status: :internal_server_error }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end
end
