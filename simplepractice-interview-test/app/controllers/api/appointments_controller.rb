class Api::AppointmentsController < ApplicationController
  # get request for appointments
  def index
    # filtering appointments based on url
    if !request.query_string.present?
      # TODO: return all values
      # GET api/appointments
      appointments = appointmentArray(Appointment.preload(:doctor, :patient))
      logger.debug { "Obtaining all appointments" }
    else
      filteredAppts = Appointment

      # TODO: return filtered values
      # filtering appointments by time period
      if params.has_key?(:past)
        # GET api/appointments/?past=1 <- past appointments
        # GET api/appointments/?past=0 <- future appointments
        case params[:past]
        when "1"
          logger.debug { "Obtaining past appointments" }
          filteredAppts = filteredAppts.where("start_time < ?", Time.now)
        when "0"
          logger.debug { "Obtaining future appointments" }
          filteredAppts = filteredAppts.where("start_time > ?", Time.now)
        else
          logger.debug { "Unknown value for :past" }
        end
      end

      # checking if length hand page parameters both present
      if params.has_key?(:length) || params.has_key?(:page)
        # adjusting number of results based on page number and page length
        if params.has_key?(:length) && params.has_key?(:page)
          # GET api/appointments/?length=[int]&page=[int]
          #checking if length is integer
          if is_int?(params[:length]) && is_int?(params[:page])
            page = params[:page].to_i
            length = params[:length].to_i

            # checking if :length and :page are positive numbers
            if page > 0 && length > 0
              skippedRecords = length*(page - 1)
              logger.debug { "Obtaining appointments on page #{page} of length #{length}" }
              logger.debug { "Skipping #{skippedRecords} results" }
              filteredAppts = filteredAppts.limit(length).offset(skippedRecords)
            else
              logger.debug { ":length and :page parameters not both positive" }
            end
          else
            logger.debug { ":length and :page parameters not both ints" }
          end
        else
          logger.debug { ":length and :page parameters not both present" }
        end
      end

      appointments = appointmentArray(filteredAppts.preload(:doctor, :patient))
    end

    logger.debug { "Found #{appointments.length} appointments" }
    logger.debug { "Sample appointments: #{appointments.sample(3)}" }
    render :json => appointments, :status => :ok
  end

  # posts a new appointment to database
  def create
    # TODO:
    # POST api/appointments
    params.require(:patient).require(:name)
    params.require(:doctor).require(:id)
    params.require(:start_time)
    params.permit(:duration_in_minutes)
    logger.debug { "Creating new appointment" }

    # post parameters: { patient: { name: <string> }, doctor: { id: <int> }, start_time: <iso8604>, 
    # duration_in_minutes: <int> }
    drId = params[:doctor][:id]

    # checking if doctor with inputted id exists
    if !Doctor.exists?(drId)
      logger.debug { "Error. Doctor with id #{drId} does not exist."}
      render :json => {
        status: "error",
        message: "Doctor with id #{drId} does not exist.",
        code: 404
      }, :status => :not_found
      return head(:not_found)
    end

    ptName = params[:patient][:name]
    patient = Patient.where(name: ptName).first_or_initialize

    # checking if patient assigned the correct doctor
    if patient.doctor_id == nil
      logger.debug { "Creating patient #{ptName}" }
      patient.doctor_id = drId
    elsif patient.doctor_id != drId
      logger.debug { "Error. Patient #{ptName} assigned doctor other than doctor #{patient.doctor.id}." }
      render :json => {
        status: "error",
        message: "Error. Patient #{ptName} assigned doctor other than doctor #{patient.doctor.id}.",
        code: 404
      }, :status => :not_found
      return head(:not_found)
    end

    patient.save
    logger.debug { "Patient: #{patient.inspect}" }

    appointment = Appointment.new(
      doctor_id: drId,
      patient_id: patient.id,
      start_time: params[:start_time]
    )

    # adding duration if provided
    if params[:duration_in_minutes] != nil
      appointment.duration_in_minutes = params[:duration_in_minutes]
    end

    if appointment.save
      logger.debug { "New appointment: #{appointment.inspect}"}
      render :json => appointment, :status => :ok
    else
      logger.debug { "Appointment creation failed."}
      logger.debug { appointment.errors.full_messages }
      render :json => {
        status: "error",
        message: appointment.errors.full_messages ,
        code: 400
      }, :status => :bad_request
      return head(:bad_request)
    end
  end

  private

  # checks if a string is an integer
  # @param string - a string
  # returns true if string is a integer, false otherwise
  def is_int? string
    true if Integer(string) rescue false
  end

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