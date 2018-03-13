class RssiController < ApplicationController
  before_filter :set_calibration
  before_filter :calibrated?, except: [:calibration, :ongoing, :get_last_values, :register]

  def index
  end

  def get_last_values
    if @calibration.calibrated?

      limit = params[:limit]
      limit ||= 20

      offset = params[:offset]

      # time_window = @calibration.get_time_window
      # # @rssi = Rssi.all.where("id < 4275")
      # # @rssi = Rssi.where("id >= 4275").order(id: :asc).offset(offset).limit(limit)
      # @rssi = Rssi.order(id: :asc).last(limit.to_i)
      # value = 0
      # # @rssi.last(time_window).each{ |rssi| ap(rssi); value += rssi.value }

      # algorithm = @calibration.algorithm
      # value = algorithm.produce_value @rssi.last(time_window)
      # puts "VALUE: #{value}"
      # # value = (value.to_f/time_window).ceil
      # result = algorithm.predict(value)
      # # result = false

      # puts "SEATED: #{result}"

      @preds = Prediction.order(id: :asc).last(limit.to_i)
      result = @preds.last.present? ? @preds.last.predicted_seated : false

      # result = false
      respond_to do |format|
        format.json { render json: {values: @preds.map(&:prediction_value), result: result} }
      end
    else
      respond_to do |format|
        format.json { render json: {values: [], result: false, message: "System not calibrated"}, status: 400 }
      end
    end
  end

  def pause
    @calibration.pause_calibration

    redirect_to root_path
  end

  def resume
    gender = params[:gender]
    weight = params[:weight]
    height = params[:height]
    seated = params[:seated]
    seated = seated.blank? ? false : true
    @calibration.gender = gender
    @calibration.weight = weight
    @calibration.height = height
    @calibration.actual_seated = seated
    @calibration.save
    @calibration.resume_calibration

    redirect_to root_path
  end

  # def calibration
  #   if @calibration.ongoing?
  #     redirect_to :ongoing
  #   elsif @calibration.calibrated?
  #     redirect_to root_path
  #   end
  # end

  def register
    rssi = params[:rssi]

    if !@calibration.pause
      if @calibration.ongoing?
        outcome = @calibration.outcome
        current_iteration = @calibration.current_iteration
        TrainingData.create!(value: rssi, outcome: outcome, iteration: current_iteration)
      elsif @calibration.calibrated?
        limit = params[:limit]
        limit ||= 20
        Rssi.create!(value: rssi)

        time_window = @calibration.get_time_window
        # @rssi = Rssi.all.where("id < 4275")
        # @rssi = Rssi.where("id >= 4275").order(id: :asc).offset(offset).limit(limit)
        @rssi = Rssi.order(id: :asc).last(limit.to_i)
        value = 0
        # @rssi.last(time_window).each{ |rssi| ap(rssi); value += rssi.value }

        algorithm = @calibration.algorithm
        value = algorithm.produce_value @rssi.last(time_window)
        puts "VALUE: #{value}"
        # value = (value.to_f/time_window).ceil
        result = algorithm.predict(value)

        pred = Prediction.new
        pred.actual_seated = @calibration.actual_seated
        pred.prediction_value = value
        pred.predicted_seated = result
        pred.algorithm_class = @calibration.algorithm_class
        if @calibration.actual_seated
          pred.gender = @calibration.gender
          pred.height = @calibration.height
          pred.weight = @calibration.weight
        end
        pred.save
      end
    end
  end

  def ongoing
    if !@calibration.calibrated?
      redirect_to start_calibration_path
    end
  end

private
  def calibrated?
    if @calibration.ongoing?
      redirect_to :ongoing
    elsif !@calibration.calibrated?
      redirect_to calibration_path
    end
  end

  def set_calibration
    @calibration = Calibration.last
    if @calibration.blank?
      raise "System failure!"
    end
  end
end
