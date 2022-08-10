class Api::DoctorsController < ApplicationController
  # obtains all doctors that don't have an appointment
  def free
    @doctors = nil

    # ensuring that there is no url query
    if request.query_string.present?
      logger.debug { "Error. Unrecognized query string"}
      return head(:bad_request)
    end

    # GET api/doctors
    logger.debug { "Finding doctors without appointments" }  
    @doctors = Doctor.left_outer_joins(:appointments).where(appointments: {id: nil})
    logger.debug { "Found #{@doctors.count} doctors with no appointments"}
    logger.debug { "Free doctors: #{@doctors.limit(5).inspect}"}
    head :ok
  end
end