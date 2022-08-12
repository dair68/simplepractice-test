class Api::DoctorsController < ApplicationController
  # obtains all doctors that don't have an appointment
  def free
    # GET api/doctors
    logger.debug { "Finding doctors without appointments" }  
    @doctors = Doctor.left_outer_joins(:appointments).where(appointments: {id: nil})
    logger.debug { "Found #{@doctors.count} doctors with no appointments"}
    logger.debug { "Sample free doctors: #{@doctors.limit(5).inspect}"}
    head :ok
  end
end