class BlockGeneratorJob < ApplicationJob
  queue_as :default

  def perform(mode, id = nil)
    case mode
    when "schedule"
      schedule = AvailabilitySchedule.find_by(id: id)
      return unless schedule
      BlockGenerator.new(schedule.professional).regenerate_schedule(schedule)
    when "professional"
      professional = Professional.find_by(id: id)
      return unless professional
      BlockGenerator.new(professional).regenerate_all
    when "global"
      # Extiende bloques 1 semana más para todos los profesionales con schedules
      from = 3.weeks.from_now.to_date
      to = 4.weeks.from_now.to_date
      Professional.joins(:availability_schedules).distinct.find_each do |pro|
        BlockGenerator.new(pro).generate(from: from, to: to)
      end
    end
  end
end
