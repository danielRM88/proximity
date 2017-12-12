class RssiController < ApplicationController
  def index
    @rssi = Rssi.all
  end

  def register
    rssi = params[:rssi]

    Rssi.create!(value: rssi)
  end
end
