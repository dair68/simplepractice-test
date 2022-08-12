class Api::AppointmentsController < ApplicationController
  # get request for appointments
  def index
    # filtering appointments based on url
    if !request.query_string.present?
      # TODO: return all values
      # GET api/appointments
      @appointments = appointmentArray(Appointment.preload(:doctor, :patient))
      logger.debug { "Obtaining all appointments" }
    else
      filteredAppts = Appointment

      # TODO: return filtered values
      # filtering appointments by time period
      if params.has_key?(:past)
        # GET api/appointments/?past=1 <- past appointments
        # GET api/appointments/?past=0 <- future appointments
        if params[:past] == "1"
          logger.debug { "Obtaining past appointments" }
          filteredAppts = filteredAppts.where("start_time < ?", Time.now)
        elsif params[:past] == "0"
          logger.debug { "Obtaining future appointments" }
          filteredAppts = filteredAppts.where("start_time > ?", Time.now)
        end
      end

      # adjusting number of results based on page number and page length
      if params.has_key?(:length) && params.has_key?(:page)
        # GET api/appointments/?length=[int]&page=[int]
        page = params[:page].to_i
        length = params[:length].to_i
        logger.debug { "Obtaining appointments on page #{page} of length #{length}" }
        skippedRecords = length*(page - 1)
        logger.debug { "Skipping #{skippedRecords} results" }

        # checking that k is nonnegative integer
        if skippedRecords > 0
          filteredAppts = filteredAppts.limit(length).offset(skippedRecords)
        end
      end

      @appointments = appointmentArray(filteredAppts.preload(:doctor, :patient))
    end

    logger.debug { "Found #{@appointments.length} appointments" }
    logger.debug { "Sample appointments: #{@appointments.sample(3)}" }
    head :ok
  end

  # posts a new appointment to database
  def create
    # TODO:
    # POST api/appointments
    params.require(:patient).require(:name)
    params.require(:doctor).require(:id)
    params.require(:appointment).permit(:start_time, :duration_in_minutes)
    logger.debug { "Creating new appointment" }

    # post parameters: { patient: { name: <string> }, doctor: { id: <int> }, start_time: <iso8604>, 
    # duration_in_minutes: <int> }
    drId = params[:doctor][:id]
    ptName = params[:patient][:name]
    ptId = Patient.where(doctor_id: drId).find_by(name: ptName).id

    @appointment = Appointment.new(
      doctor_id: drId,
      patient_id: ptId,
      start_time: params[:start_time],
    )

    # adding duration in minutes to record if provided by body
    if params.has_key?(:duration_in_minutes)
      @appointment.duration_in_minutes = params[:duration_in_minutes]
    end

    if @appointment.save
      logger.debug { "New appointment: #{@appointment.inspect}"}
    else
      logger.debug { "Appointment creation failed."}
    end
    head :ok
  end

  private

  # creates an array of hash tables based on an appointment object
  # @param apptRecords - Appointment model or relation
  # returns array of form [{id: <int>, patient: { name: <string> }, doctor : { name: <string>, id: <int> },
  # created_at: <iso8601>, start_time: <iso8601>, duration_in_minutes: <int>}, ...]
  def appointmentArray(apptRecords)
    apptArray = []

    # assembling appointment records into an array of a specific format
    apptRecords.find_each do |appt|
      apptObject = {
        id: appt.id,
        patient: { name: appt.patient.name },
        doctor: { 
          name: appt.doctor.name,
          id: appt.doctor.id
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