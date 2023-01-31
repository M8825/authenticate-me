class User < ApplicationRecord
  has_secure_password

  before_validation :ensure_session_token

  validates :username, :session_token, :email, presence: true, uniqueness: true

  validates :username, length: { in: 3..30 }

  validates :email,
            length: {
              in: 3..255
            },
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }

  validates :username,
            format: {
              without: URI::MailTo::EMAIL_REGEXP,
              message: "can't be an email"
            }

  validates :password, length: { in: 6..255, allow_nil: true }

  def self.find_by_credentials(credential, password)
    field = credential =~ URI::MailTo::EMAIL_REGEXP ? :email : :username
    user = User.find_by(field => credential)

    user if user && user.authenticate(password)
  end

  def reset_session_token!
    self.session_token = generate_unique_session_token
    self.save!
    self.session_token
  end

  private

  def generate_unique_session_token
    token = SecureRandom.base64
    token = SecureRandom.base64 while User.exists?(session_token: token)

    return token
  end

  def ensure_session_token
    self.session_token =
      generate_unique_session_token if self.session_token.nil?
  end
end
