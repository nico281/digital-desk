class BlockGenerator
  def initialize(professional)
    @professional = professional
    @duration = professional.block_duration_minutes
    @buffer = professional.buffer_minutes
  end

  def generate(from: Date.tomorrow, to: 4.weeks.from_now.to_date)
    schedules = @professional.availability_schedules.to_a
    return if schedules.empty?

    (from..to).each do |date|
      day_schedules = schedules.select { |s| s.day_of_week == date.wday }
      day_schedules.each { |schedule| generate_blocks_for(schedule, date) }
    end
  end

  def regenerate_schedule(schedule, from: Date.tomorrow, to: 4.weeks.from_now.to_date)
    # Limpiar bloques futuros available de este schedule
    @professional.availability_blocks
      .where(availability_schedule: schedule)
      .where(status: :available)
      .where("date >= ?", from)
      .delete_all

    (from..to).each do |date|
      next unless date.wday == schedule.day_of_week
      generate_blocks_for(schedule, date)
    end
  end

  def regenerate_all(from: Date.tomorrow, to: 4.weeks.from_now.to_date)
    # Limpiar todos los bloques futuros available
    @professional.availability_blocks
      .where(status: :available)
      .where("date >= ?", from)
      .delete_all

    generate(from: from, to: to)
  end

  private

  def generate_blocks_for(schedule, date)
    cursor = schedule.start_time
    schedule_end = schedule.end_time
    blocks = []

    while advance(cursor, @duration) <= schedule_end
      block_end = advance(cursor, @duration)

      blocks << {
        professional_id: @professional.id,
        availability_schedule_id: schedule.id,
        date: date,
        start_time: cursor.strftime("%H:%M"),
        end_time: block_end.strftime("%H:%M"),
        status: 0, # available
        created_at: Time.current,
        updated_at: Time.current
      }

      cursor = advance(block_end, @buffer)
    end

    # insert_all ignora duplicados por unique index
    AvailabilityBlock.insert_all(blocks) if blocks.any?
  end

  def advance(time, minutes)
    time + minutes.minutes
  end
end
