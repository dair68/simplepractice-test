class Appointment < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient

  validates :duration_in_minutes, numericality: { only_integer: true }
  validate :nonnegative_duration

  private

  # ensuring duration is nonnegative number
  def nonnegative_duration
    # checking if duration is negative
    if duration_in_minutes < 0
      errors.add(:duration_in_minutes, "cannot be negative")
    end
  end
end
