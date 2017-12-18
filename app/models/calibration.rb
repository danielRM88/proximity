class Calibration < ActiveRecord::Base

  def algorithm
    return self.algorithm_class.constantize
  end

  def set_algorithm algorithm
    self.records = algorithm.records_needed_for_calibration
    self.algorithm_class = algorithm.to_s
  end

  def pause_calibration
    self.pause = true
    self.save
  end

  def resume_calibration
    self.pause = false
    self.save
  end

  def start_calibration
    self.calibrated = false
    self.ongoing = true
    self.outcome = false
    self.pause = false
    self.current_iteration = 1
    self.save
    TrainingData.destroy_all
    Rssi.destroy_all
  end

  def end_calibration
    self.calibrated = true
    self.ongoing = false
    # rssi = Rssi.all
    # self.result = rssi.average(:value)
    TrainingData.export
    algorithm.train
    self.save
  end

  def get_time_window
    algorithm.get_time_window
  end

  def finished?
    training_data = TrainingData.count
    finished = false
    # if self.algorithm_class == LogisticRegression.to_s
      finished = training_data >= (self.records*self.iterations)
    # else
      # finished = training_data >= (self.records)
    # end

    return finished
  end
end
