class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         jwt_revocation_strategy: JwtDenylist
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