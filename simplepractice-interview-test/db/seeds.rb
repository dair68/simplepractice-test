# TODO: Seed the database according to the following requirements:
# - There should be 10 Doctors with unique names
# - Each doctor should have 10 patients with unique names
# - Each patient should have 10 appointments (5 in the past, 5 in the future)
# - Each appointment should be 50 minutes in duration
Doctor.destroy_all
Patient.destroy_all
Appointment.destroy_all

currentTime = Time.now

# creating 10 doctors
10.times do
  dr = Doctor.create(name: Faker::Name.unique.name)

 # creating 10 patients for this doctor
  10.times do
    pt = Patient.create(
      doctor_id: dr.id,
      name: Faker::Name.unique.name
    )

    # creating 5 appointments in the past for this patient
    5.times do
      Appointment.create(
        doctor_id: dr.id,
        patient_id: pt.id,
        start_time: Faker::Time.backward(days: 365),
        duration_in_minutes: 50
      )
    end

    # creating 5 appointments in the future for this patient
    5.times do
      Appointment.create(
        doctor_id: dr.id,
        patient_id: pt.id,
        start_time: Faker::Time.forward(days: 365),
        duration_in_minutes: 50
      )
    end
  end
end

Rails.logger.debug { "Created #{Doctor.count} doctors" }
Rails.logger.debug { "Sample doctors: #{Doctor.limit(5).inspect}" }

Rails.logger.debug { "Created #{Patient.count} patients" }
dr = Doctor.first
pts = Patient.where(doctor_id: dr.id)
Rails.logger.debug { "Dr. #{dr.name} has #{pts.count} patients" }
Rails.logger.debug { "Dr. #{dr.name} sample patients: #{pts.limit(5).inspect}" }

Rails.logger.debug { "Created #{Appointment.count} appointments" }
pt = Patient.first
pastAppts = Appointment.where(patient_id: pt.id).where("start_time < ?", currentTime)
futureAppts = Appointment.where(patient_id: pt.id).where("start_time > ?", currentTime)

Rails.logger.debug { "Patient #{pt.name} has #{pastAppts.count + futureAppts.count} appointments" }
Rails.logger.debug { "Patient #{pt.name} has #{pastAppts.count} past appointments" }
Rails.logger.debug { "Patient #{pt.name} sample past appointments: #{pastAppts.limit(5).inspect}" }
Rails.logger.debug { "Patient #{pt.name} has #{futureAppts.count} future appointments" }
Rails.logger.debug { "Patient #{pt.name} sample future appointments: #{futureAppts.limit(5).inspect}" }