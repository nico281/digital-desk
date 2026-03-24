class CommissionCalculator
  TIERS = [
    { max_bookings: 10,  rate: 0.00 },
    { max_bookings: 50,  rate: 0.05 },
    { max_bookings: 150, rate: 0.07 },
    { max_bookings: nil, rate: 0.10 }
  ].freeze

  MP_RATE = 0.0499 # MercadoPago fee on total

  def initialize(professional)
    @professional = professional
  end

  def platform_rate
    completed = @professional.bookings.completed.count

    tier = TIERS.find { |t| t[:max_bookings].nil? || completed <= t[:max_bookings] }
    tier[:rate]
  end

  def calculate(net_price)
    commission = net_price * platform_rate
    subtotal = net_price + commission
    mp_fee = subtotal * MP_RATE
    total = subtotal + mp_fee

    {
      net_price: net_price,
      platform_commission: commission.round(2),
      platform_rate: platform_rate,
      mp_fee: mp_fee.round(2),
      total: total.round(2)
    }
  end
end
