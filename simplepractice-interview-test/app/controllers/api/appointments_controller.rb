class Api::AppointmentsController < ApplicationController
  #get request for appointments
  def index
    # TODO: return all values
    # GET /api/appointments
    if !request.query_string.present?
      filteredAppts = Appointment.all
      @appointments = toAppointmentArray(filteredAppts)
      logger.debug { "Obtained all #{@appointments.length} appointments" }
      logger.debug { "All appointments: #{@appointments.inspect}" }
    # TODO: return filtered values
    # GET /api/appointments/?past=1. returns past appointments
    elsif params[:past] == "1"
      filteredAppts = Appointment.where("start_time < ?", Time.now)
      @appointments = toAppointmentArray(filteredAppts)
      logger.debug { "Obtained #{@appointments.length} past appointments" }
      logger.debug { "Past appointments: #{@appointments.inspect}" }
    # GET /api/appointments/?past=0. returns future appointments
    elsif params[:past] == "0"
      filteredAppts = Appointment.where("start_time > ?", Time.now)
      @appointments = toAppointmentArray(filteredAppts)
      logger.debug { "Obtained #{@appointments.length} future appointments" }
      logger.debug { "Future appointments: #{@appointments.inspect}" }
    else
      @appointments = nil
      logger.debug { "Error. Couldn't process request for #{request.fullpath}" }
    end
    head :ok
  end

  def create
    # TODO:
  end

  private

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
  def toAppointmentArray(appointmentRecord)
    apptArray = []

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

      apptArray.push(apptObject)
    end

    return apptArray
  end

end
