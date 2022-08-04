# TODO: Seed the database according to the following requirements:
# - There should be 10 Doctors with unique names
# - Each doctor should have 10 patients with unique names
# - Each patient should have 10 appointments (5 in the past, 5 in the future)
#   - Each appointment should be 50 minutes in duration
Doctor.destroy_all
Patient.destroy_all
Appointment.destroy_all

#creating 10 doctors
10.times do |i|
  doc = Doctor.create!(name: Faker::Name.unique.name)

 #creating 10 patients for this doctor
  10.times do
    pt = Patient.create(
      doctor_id: doc.id,
      name: Faker::Name.unique.name
    )

    t = Time.now

    #creating 5 appointments in the past
    (1..5).each do |k|
      Appointment.create(
        doctor_id: doc.id,
        patient_id: pt.id,
        start_time: t.prev_day(k),
        duration_in_minutes: 50
      )
    end

    #creating 5 appointments in the future
    (1..5).each do |k|
      Appointment.create(
        doctor_id: doc.id,
        patient_id: pt.id,
        start_time: t.next_day(k),
        duration_in_minutes: 50
      )
    end
  end
end

Rails.logger.debug {"Created #{Doctor.count} doctors"}
Rails.logger.debug {"Doctors: #{Doctor.all.inspect}"}

Rails.logger.debug {"Created #{Patient.count} patients"}
Rails.logger.debug {"Patients: #{Patient.all.inspect}"}

#p "Created #{Appointment.count} appointments"
#Appointment.where(patient_id: Patient.first.id).each do |a|
#  p a
#end