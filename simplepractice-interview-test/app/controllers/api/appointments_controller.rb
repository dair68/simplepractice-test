class Api::AppointmentsController < ApplicationController
  #get request for appointments
  def index
    @resArray = nil

    # GET /api/appointments
    # TODO: return all values
    if !request.query_string.present?
      appts = Appointment.all
      @resArray = toAppointmentArray(appts)
      logger.debug { "Obtained all #{@resArray.length} appointments" }
      logger.debug { "All appointments: #{@resArray.inspect}" }
    # TODO: return filtered values
    # GET /api/appointments/?past=1. returns past appointments
    elsif params[:past] == "1"
      appts = Appointment.where("start_time < ?", Time.now)
      @resArray = toAppointmentArray(appts)
      logger.debug { "Obtained #{@resArray.length} past appointments" }
      logger.debug { "Past appointments: #{@resArray.inspect}" }
    # GET /api/appointments/?past=0. returns future appointments
    elsif params[:past] == "0"
      appts = Appointment.where("start_time > ?", Time.now)
      @resArray = toAppointmentArray(appts)
      logger.debug { "Obtained #{@resArray.length} future appointments" }
      logger.debug { "Future appointments: #{@resArray.inspect}" }
    else
      @resArray = Array.new
      logger.debug { "Error. Couldn't process for #{request.fullpath}" }
    end

    head :ok
    return @resArray
  end

  #takes an appointment active record object and returns array of form
  #[
  #  {
  #    id: <int>,
  #    patient: { name: <string> },
  #    doctor : { name: <string>, id: <int> },
  #    created_at: <iso8601>,
  #    start_time: <iso8601>,
  #    duration_in_minutes: <int>
  #  }, ...
  #]
  def toAppointmentArray (appointmentRecord)
    @responseArray = Array.new

    #converting appointment object to array
    appointmentRecord.each do |appt|
      pt = Patient.find(appt.patient_id)
      dr = Doctor.find(appt.doctor_id)

      apptObject = {
        id: appt.id,
        patient: { name: pt.name },
        doctor: { 
          name: dr.name,
          id: dr.id
        },
        created_at: appt.created_at,
        start_time: appt.start_time,
        duration_in_minutes: appt.duration_in_minutes
      }

      @responseArray.push(apptObject)
    end

    return @responseArray
  end

  def create
    # TODO:
  end
end
