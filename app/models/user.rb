class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         jwt_revocation_strategy: JwtDenylist
  has_and_belongs_to_many :organizations
  def jwt_payload
    {
      'meta': {
        'id': id,
        'email': email,
        'name': name,
        'admin': admin
      }
    }
  end
end