class CalibrationController < ApplicationController
  before_filter :set_calibration

  def index
  end

  def start
    records = params[:records]
    iterations = params[:iterations]
    algorithm = params[:algorithm]

    @calibration.records = records
    @calibration.iterations = iterations
    @calibration.algorithm_class = algorithm.to_s
    @calibration.save

    @calibration.start_calibration
    if @calibration.algorithm == LogisticRegression
      view = "calibration/lg/calibration"
    else
      view = "calibration/as/calibration"
    end

    view = "calibration/lg/calibration"
    render view
  end

  def pause
    @calibration.pause_calibration
  end

  def resume
    @calibration.resume_calibration
    if @calibration.algorithm == LogisticRegression
      view = "calibration/lg/calibration"
    else
      view = "calibration/as/calibration"
    end

    view = "calibration/lg/calibration"
    render view
  end

  def end
    @calibration.end_calibration
    redirect_to root_path
  end

  def retrain
    algorithm = params[:algorithm]
    upload = params[:trainingFile]
    upload = nil if upload.blank?

    File.open(Rails.root.join('training', 'training_data.csv'), 'wb') do |file|
      file.write(upload.read)
    end

    @calibration.update(algorithm_class: algorithm.to_s)
    @calibration.end_calibration
    redirect_to root_path
  end

  def progress
    if @calibration.finished?
      status = 241
      count = 100
      @calibration.pause = false
      @calibration.outcome = false
      @calibration.save
    else
      status = 200
      count = TrainingData.where(outcome: @calibration.outcome, iteration: @calibration.current_iteration).count
      records = @calibration.records
      outcome = @calibration.outcome
      if count >= records
        @calibration.pause_calibration
        @calibration.outcome = !@calibration.outcome
        @calibration.current_iteration += 1
        @calibration.save
        status = 240
      end
      count = (count*100)/records
    end

    respond_to do |format|
      format.json { render json: {progress: count, outcome: outcome}, status: status }
    end
  end

private
  def set_calibration
    @calibration = Calibration.last
    if @calibration.blank?
      Calibration.create!
      @calibration = Calibration.last
    end
  end
end
