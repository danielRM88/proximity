require 'csv'
class AverageSquare < Algorithm
  CALIBRATION_RECORDS = 150
  DESICION_BOUNDARY = -5
  TIME_WINDOW = 5

  def self.train
    avg = 0
    value = 0

    csv_text = File.read("#{Rails.root}/training/training_data.csv")
    csv = CSV.parse(csv_text, :headers => true)
    cont = 1
    csv.each do |row|
      value += row["values"].to_i
      cont += 1
    end

    avg = value / cont
    c = Calibration.last
    c.result = avg
    c.save
  end

  def self.records_needed_for_calibration
    return CALIBRATION_RECORDS
  end

  def self.get_time_window
    return TIME_WINDOW
  end

  def self.produce_value array
    value = 0
    if array.length > 0
      array = array.map(&:value)
      puts "ARRAY: #{array}"
      sorted = array.sort
      len = sorted.length

      value = (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end

    return value
  end

  def self.predict value
    c = Calibration.last
    training_avg = c.result

    result = (value - training_avg)

    return result < DESICION_BOUNDARY
  end
end