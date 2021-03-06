class Application
  include Mongoid::Document
  field :name, type: String
  field :token, type: String
  has_many :reports
  has_many :builds
  has_many :invitations
  embeds_one :setting, autobuild: true

  before_create :generate_token

  def accesses
    ApplicationAccess.where(application_id: self.id)
  end

  def users
    user_ids = accesses.map(&:user_id)
    User.in(id: user_ids)
  end

  def email_list
    emails = []
    self.users.each { |u| emails << u.email unless u.email.nil?}
    emails
  end

  protected

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token if Application.where(token: random_token).empty?
    end
  end
end
