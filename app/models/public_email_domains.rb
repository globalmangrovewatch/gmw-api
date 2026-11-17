module PublicEmailDomains
  DOMAINS = %w[
    aol.com
    fastmail.com
    gmail.com
    gmx.com
    gmx.net
    googlemail.com
    hey.com
    hotmail.com
    icloud.com
    live.com
    mac.com
    mail.com
    me.com
    msn.com
    outlook.com
    pm.me
    proton.me
    protonmail.com
    rocketmail.com
    tuta.com
    tutanota.com
    yahoo.co.uk
    yahoo.com
    yandex.com
    yandex.ru
    ymail.com
    zoho.com
  ].freeze

  def self.public?(domain)
    DOMAINS.include?(domain.to_s.downcase)
  end

  def self.domain_from(email)
    local, domain = email.to_s.strip.downcase.split("@", 2)
    return if local.blank? || domain.blank?

    domain
  end
end
