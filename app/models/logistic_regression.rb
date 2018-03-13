class LogisticRegression < Algorithm
  DESICION_BOUNDARY = 0.70

  def self.train
    R.eval %Q[
      # data = read.csv("/Users/danielrosato/Documents/Politecnico\ di\ Milano/3rd\ Semester/Pervasive\ Systems/sitting_sensor/training/past_data/training_data_with_outliers.csv")
      # data = read.csv("/Users/danielrosato/Desktop/PredictionData.csv")
      data = read.csv("#{Rails.root}/training/training_data.csv")
      attach(data)
      max = max(id)
      max_train_id = floor((max*70)/100)
      # train = (id<1084)
      # train = (id<790)
      train = (id<max_train_id)
      data = data[!train,]
      glm.fit=glm(seated~values, data=data, family=binomial, subset=train)
      glm.probs=predict(glm.fit, data, type="response")
      remaining = length(train) - max_train_id
      glm.pred=rep(0, remaining)
      glm.pred[glm.probs > #{DESICION_BOUNDARY}] = 1
    ]

    puts "remaining: #{R.remaining}"
  end

  def self.produce_value array
    value = 0
    array.each{ |rssi| ap(rssi); value += rssi.value }
    value = (value.to_f/TIME_WINDOW).ceil

    return value
  end

  def self.predict value
    R.eval %Q[
      result = predict(glm.fit, data.frame(values = #{value}), type="response")
    ]

    puts "Probability: #{R.result}"
    
    return R.result > DESICION_BOUNDARY
  end
end