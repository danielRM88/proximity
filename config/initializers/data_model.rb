require 'descriptive_statistics'
# require 'rootapp-rinruby'
if defined?(Rails::Server)
  require 'rinruby'
  if ENV['DATAMODEL'] == 'lg'
    # puts "Initialising and Training Logistic Regression Model"
    # LogisticRegression.init
    algorithm = LogisticRegression
    iterations = 2
  elsif ENV['DATAMODEL'] == 'as'
    algorithm = AverageSquare
    iterations = 1
  else
    algorithm = LogisticRegression
  end

  calibration = Calibration.last
  if calibration.blank?
    Calibration.create(records: algorithm.records_needed_for_calibration, algorithm_class: algorithm.to_s, iterations: iterations)
  elsif calibration.algorithm_class != algorithm.to_s
    Calibration.destroy_all
    Calibration.create(records: algorithm.records_needed_for_calibration, algorithm_class: algorithm.to_s, iterations: iterations)
  else
    calibration.set_algorithm algorithm
    calibration.save
  end
end
