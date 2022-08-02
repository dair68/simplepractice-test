# TODO: Seed the database according to the following requirements:
# - There should be 10 Doctors with unique names
# - Each doctor should have 10 patients with unique names
# - Each patient should have 10 appointments (5 in the past, 5 in the future)
#   - Each appointment should be 50 minutes in duration
Doctor.destroy_all
Doctor.create!(
[
    {
        name: "Florence Nightingale"
    },
    {
        name: "Susan La Flesche Picotte"
    },
    {
        name: "Louis Pasteur"
    },
    {
        name: "Alexander Fleming"
    },
    {
        name: "Mario Mario"
    },
    {
        name: "Phil McGraw"
    },
    {
        name: "Julius Hibbert"
    },
    {
        name: "Sigma Klim"
    },
    {
        name: "Ken Jeong"
    },
    {
        name: "Emily Zarka"
    }
])

p "Created #{Doctor.count} doctors"
Doctor.all.each do |n|
    p n
end