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
 doc = Doctor.create!(name: "Doctor #{i}")

 #creating 10 patients for this doctor
 10.times do
  pt = Patient.create(
        doctor_id: doc.id,
        name: "Patient #{Patient.count}"
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

p "Created #{Doctor.count} doctors"
Doctor.all.each do |doc|
 p doc
end

p "Created #{Patient.count} patients"
Patient.where(doctor_id: Doctor.first.id).each do |pt|
 p pt
end

p "Created #{Appointment.count} appointments"
Appointment.where(patient_id: Patient.first.id).each do |a|
 p a
end