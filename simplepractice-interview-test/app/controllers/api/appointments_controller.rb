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
      #checking if query parameters valid
      validParameters = Set["past", "length", "page"]
      #logger.debug { "query parameters: #{request.query_parameters}" }
      request.query_parameters.each_key do |key|
        #found invalid parameter
        if !validParameters.include?(key)
          logger.debug { "Error. Can't process request for #{request.fullpath}" }
          return  
        end  
      end

      # TODO: return filtered values
      #filtering appointments by past or future
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
          logger.debug { "Error. ?past=#{params[:past]} is invalid value" }
          return
        end
      end

      #checking if url has both :length and :page parameters
      if (params.has_key?(:length) && !params.has_key?(:page)) || (!params.has_key?(:length) && params.has_key?(:page))
        logger.debug { "Error. :length and :page parameters not both present in query." }
        return
      end

      #adjusting number of results based on page number and page length
      if params.has_key?(:length) && params.has_key?(:page)
        # GET /api/appointments/?length=[int]&page=[int]
        page = params[:page].to_i
        length = params[:length].to_i

        #checking if page number valid
        if page <= 0
          logger.debug { "Error. ?page=#{page} is invalid value" }
          return
        end

        #checking if page length valid
        if length <= 0
          logger.debug { "Error. ?length=#{length} is invalid value" }
          return
        end 

        logger.debug { "Obtaining appointments on page #{page} of length #{length}" }
        k = length*(page - 1)
        logger.debug { "Skipping #{k} results" }
        filteredAppts = filteredAppts.limit(length).offset(k)
      end
    end

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
