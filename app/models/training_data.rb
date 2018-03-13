require 'csv'
class TrainingData < ActiveRecord::Base
  def self.export path = "#{Rails.root}/training/training_data.csv"
    # file_name = "training_data.csv"
    file = path# + file_name

    data = TrainingData.all

    attributes = %w{id values seated}
    cont = 1
    CSV.open(file, "wb", headers: true) do |csv|
      csv << attributes

      data.each do |data|
        outcome = data.outcome ? 1 : 0
        csv << [cont, data.value, outcome]
        cont += 1
      end
    end
  end
end
