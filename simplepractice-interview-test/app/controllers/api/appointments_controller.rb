class Api::AppointmentsController < ApplicationController
  #get request for appointments
  def index
    # GET /api/appointments
    # TODO: return all values
    @appointments = Appointment.all
    logger.debug {"All appointments: #{@appointments.inspect}"}

    # TODO: return filtered values
    head :ok
  end

  def create
    # TODO:
  end
end
