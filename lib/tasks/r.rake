namespace :r do
  desc "Logistic Regression"
  task :logistic_regression => :environment do
    # filepath = Rails.root.join("lib", "external_scripts", "script.R")
    # output = `Rscript --vanilla #{filepath}  'Pippi Longstockings'`
    # puts output

    require "rinruby"
    R.eval %Q[
      data = read.csv("/Users/danielrosato/Documents/Politecnico di Milano/3rd Semester/Pervasive Systems/PervasiveDataCleanedChair1.csv")
      attach(data)
      train = (id<1084)
      data = data[!train,]
      glm.fit=glm(seated~values, data=data, family=binomial, subset=train)
      glm.probs=predict(glm.fit, data, type="response")
      glm.pred=rep(0, 464)
      glm.pred[glm.probs > .5] = 1
      result = predict(glm.fit, data.frame(values = -55), type="response")
      cat(result)
    ]
    puts "#{R.result}"

    # data = read.csv("/Users/danielrosato/Documents/Politecnico di Milano/3rd Semester/Pervasive Systems/PervasiveDataCleanedChair1.csv")

    # attach(data)
    # train = (id<1084)
    # data = data[!train,]
    # glm.fit=glm(seated~values, data=data, family=binomial, subset=train)
    # glm.probs=predict(glm.fit, data, type="response")
    # glm.pred=rep(0, 464)
    # glm.pred[glm.probs > .5] = 1

    # predict(glm.fit, data.frame(values = -55), type="response")
  end
end