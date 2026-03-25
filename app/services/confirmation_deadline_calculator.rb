class ConfirmationDeadlineCalculator
  THRESHOLDS = [
    { min_hours_until: 48, deadline_in: 24.hours },
    { min_hours_until: 24, deadline_in: 6.hours },
    { min_hours_until: 4,  deadline_in: 2.hours },
    { min_hours_until: 1,  deadline_in: 30.minutes }
  ].freeze

  def self.calculate(booking)
    booking_time = booking.date.to_datetime + booking.start_time.seconds_since_midnight.seconds
    hours_until = (booking_time - Time.current) / 1.hour

    return nil if hours_until < 1

    threshold = THRESHOLDS.find { |t| hours_until >= t[:min_hours_until] }
    deadline = Time.current + threshold[:deadline_in]

    # never exceed booking start
    [ deadline, booking_time - 30.minutes ].min
  end
end
