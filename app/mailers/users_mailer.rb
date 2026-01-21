class UsersMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'users/mailer'

  def reset_password_instructions(record, token, opts = {})
    @token = token
    @source = record.password_reset_source
    super
  end
end

