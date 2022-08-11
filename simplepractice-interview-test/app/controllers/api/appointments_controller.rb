class Api::AppointmentsController < ApplicationController
  # get request for appointments
  def index
    @appointments = nil

    # filtering appointments based on url
    if !request.query_string.present?
      # TODO: return all values
      # GET api/appointments
      @appointments = appointmentArray(Appointment.preload(:doctor, :patient))
      logger.debug { "Obtaining all appointments" }
    else
      # making sure query parameters are valid
      if !validIndexQueryParams
        logger.debug { "Error. Invalid query parameters."}
        return head(:bad_request)
      end

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
          logger.debug { "Error. Invalid value for ?past=" }
          return head(:bad_request)
        end
      end

      # adjusting number of results based on page number and page length
      if params.has_key?(:length) && params.has_key?(:page)
        # GET api/appointments/?length=[int]&page=[int]
        page = params[:page].to_i
        length = params[:length].to_i
        logger.debug { "Obtaining appointments on page #{page} of length #{length}" }
        k = length*(page - 1)
        logger.debug { "Skipping #{k} results" }
        filteredAppts = filteredAppts.limit(length).offset(k)
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
    logger.debug { "Creating new appointment" }

    # post parameters: { patient: { name: <string> }, doctor: { id: <int> }, start_time: <iso8604>, 
    #  duration_in_minutes: <int> }
    @appointment = Appointment.create(
      doctor_id: params[:doctor][:id],
      #patient_id: Patient.,
      start_time: params[:start_time],
      duration_in_minutes: params[:duration_in_minutes]
    )
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

  # ensures that all parameters in the index query url are valid
  # returns true is query parameters are valid, false otherwise
  def validIndexQueryParams
    validParameters = Set["past", "length", "page"]
    # ensuring there are no unknown parameters
    request.query_parameters.each_key do |key|
      # found invalid parameter
      if !validParameters.include?(key)
        logger.debug { "Error. Unknown query parameter: #{key}" }
        return false
      end
    end

    # checking ?past=
    if params.has_key?(:past)
      # ensuring ?past=1 or ?past=0
      if params[:past] != "1" && params[:past] != "0"
        logger.debug { "Error. Invalid value for ?past=" }
        return false
      end
    end

    # checking ?length=[int]&page=[int]
    if params.has_key?(:length) || params.has_key?(:page)
      # ensuring that both length and page parameters are both present
      if !(params.has_key?(:length) && params.has_key?(:page))
        logger.debug { "Error. length and page parameters not both present in url query" }
        return false
      end

      length = Integer(params[:length]) rescue false

      # ensuring that length is positive
      if length == false || length <= 0
        logger.debug { "Error. Invalid value for ?length="}
        return false
      end

      page = Integer(params[:page]) rescue false

      # ensuring that page is positive
      if page == false || page <= 0
        logger.debug { "Error. Invalid value for ?page="}
        return false
      end
    end

    return true
  end  
end