class Algorithm
  CALIBRATION_RECORDS = 120
  TIME_WINDOW = 3
  def self.records_needed_for_calibration
    return CALIBRATION_RECORDS
  end

  def self.get_time_window
    return TIME_WINDOW
  end

  def self.train
    raise "Not Implemented"
  end
end