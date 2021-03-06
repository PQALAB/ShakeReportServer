class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Mongoid::Commentable


  default_scope order_by(:updated_at => :desc)
  after_create :after_create_hook

  STATUS = {new: 0, available_on_next_build: 1 ,ready_to_test: 2, archived: 3}
  field :title, type: String
  field :message, type: String
  field :device_model, type: String
  field :os_version, type: String
  field :screenshot, type: String
  field :logs, type: String
  field :crash_logs, type: String
  field :dumped_view, type: String
  field :status, type: Integer, default: STATUS[:new]
  field :jira_ticket, type: String

  belongs_to :application
  belongs_to :build

  has_mongoid_attached_file :screen_capture
  
  validate :has_one_attribute_set
  
  scope :opened, where(:status => STATUS[:new])
  scope :available_on_next_build, where(:status => STATUS[:available_on_next_build])
  scope :ready_to_test, where(:status => STATUS[:ready_to_test])
  scope :archived, where(:status => STATUS[:archived])
  scope :today, where(:created_at.gte => Date.today)

  def message_for_ticket
    host = Rails.application.config.action_mailer.default_url_options[:host]
    m = "--------------------------------------------------------------\n"
    m = m + "OS: #{self.os_version}\n"
    m = m + "Device: #{self.device_model}\n"
    m = m + "--------------------------------------------------------------\n"
    m = m + message + "\n"
    m = m + "--------------------------------------------------------------\n"
    m = m + "Video: #{self.screen_capture.url}\n" if self.screen_capture_file_name
    m = m + "More info there: #{Rails.application.routes.url_helpers.application_report_url(self.application, self, host: host)}\n"
    m = m + "Created with Shake Report."
  end

  def after_create_hook
    emails = self.application.email_list
    ReportMailer.new_report_created(emails, self).deliver if !emails.empty?
  end

  protected
  def has_one_attribute_set
    if title.nil? && message.nil? && device_model.nil? && os_version.nil? && screenshot.nil? && logs.nil? && crash_logs.nil? && dumped_view.nil?
      errors.add(:title, 'or at least one attribute needs to be set')
    end
  end
end
