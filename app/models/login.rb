class Login
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :password
  attr_reader :user

  validates :name, presence: true
  validates :password, presence: true
  validate :authenticate

private

  def authenticate
    return unless name.present? && password.present?

    @user = User.find_by(name:)
    unless @user&.authenticate(password)
      errors.add(:base, :invalid)
    end
  end
end
