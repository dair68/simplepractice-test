class Api::AppointmentsController < ApplicationController
  #get request for appointments
  def index
    filteredAppts = Appointment
    @appointments = nil
    
    #filtering appointments based on url
    if !request.query_string.present?
      # TODO: return all values
      # GET /api/appointments
      filteredAppts = filteredAppts.all
      logger.debug { "Obtaining all appointments" }
    else
      # TODO: return filtered values
      if params.has_key?(:past)
        #filtering appointments by past for ?past=1 and future for ?past=0
        case params[:past]
        when "1"
          # GET /api/appointments/?past=1
          filteredAppts = filteredAppts.where("start_time < ?", Time.now)
          logger.debug { "Obtaining past appointments" }
        when "0"
          # GET /api/appointments/?past=0
          filteredAppts = filteredAppts.where("start_time > ?", Time.now)
          logger.debug { "Obtaining future appointments" }
        else
          logger.debug { "Error. ?past=#{params[:past]} is invalid parameter" }
          return
        end
      else
        logger.debug { "Error. Can't process request for #{request.fullpath}" }
        return
      end
    end

    # TODO: return filtered values
    # GET /api/appointments/?past=1. returns past appointments
    #elsif params[:past] == "1"
    #  filteredAppts = Appointment.where("start_time < ?", Time.now)
    #  @appointments = toAppointmentArray(filteredAppts)
    #  logger.debug { "Obtained #{@appointments.length} past appointments" }
    #  logger.debug { "Past appointments: #{@appointments.inspect}" }
    # GET /api/appointments/?past=0. returns future appointments
    #elsif params[:past] == "0"
    #  filteredAppts = Appointment.where("start_time > ?", Time.now)
    #  @appointments = toAppointmentArray(filteredAppts)
    #  logger.debug { "Obtained #{@appointments.length} future appointments" }
    #  logger.debug { "Future appointments: #{@appointments.inspect}" }
    #else
    #  @appointments = nil
    #  logger.debug { "Error. Couldn't process request for #{request.fullpath}" }
    #end

    @appointments = []

    #assembling appointment records into an array of a specific format
    filteredAppts.each do |appt|
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

    logger.debug { "Found #{@appointments.length} appointments" }
    logger.debug { "Sample appointments: #{@appointments.sample(3)}" }
    head :ok
  end

  def create
    # TODO:
  end
end
