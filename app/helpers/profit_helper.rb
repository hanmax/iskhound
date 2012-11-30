module ProfitHelper

  def full_system_name(order)
    "#{order.region.name} - #{order.solar_system.name}"
  end

  def system_security_class(order)
    security_level = order.solar_system.security
    if security_level <= 0.1
      "red_sec"
    elsif security_level > 0.1 && security_level < 0.5
      "orange_sec"
    elsif security_level > 0.5 && security_level < 0.6
      "yellow_sec"
    elsif security_level >= 0.6 && security_level < 0.9
      "green_sec"
    else
      "blue_sec"
    end
  end

end
