class Api::AppointmentsController < ApplicationController
  #get request for appointments
  def index
    # GET /api/appointments
    # TODO: return all values
    @appointments = Array.new

    #populating @appointments with appointment data in a particular format
    Appointment.all.each do |appt|
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

      @appointments.push(apptObject)
    end

    logger.debug { "Obtained #{@appointments.length} appointments" }
    logger.debug { "Appointments: #{@appointments.inspect}" }

    # TODO: return filtered values
    head :ok
  end

  def create
    # TODO:
  end
end
