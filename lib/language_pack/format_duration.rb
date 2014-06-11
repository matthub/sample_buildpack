class Numeric

 def duration
    remainder = self

    hours = (remainder / HOUR).to_int
    remainder -= HOUR * hours

    minutes = (remainder / MINUTE).to_int
    remainder -= MINUTE * minutes

    return "#{hours}h #{minutes}m" if hours > 0

    seconds = (remainder / SECOND).to_int
    remainder -= SECOND * seconds

    return "#{minutes}m #{seconds}s" if minutes > 0

    tenths = (remainder / TENTH).to_int
    "#{seconds}.#{tenths}s"
  end

  private

    MILLISECOND = 0.001.freeze

    TENTH = (100 * MILLISECOND).freeze

    SECOND = (10 * TENTH).freeze

    MINUTE = (60 * SECOND).freeze

    HOUR = (60 * MINUTE).freeze

end
