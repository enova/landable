require_dependency 'landable/author'

module Landable
  class RegistrationService
    def self.call(attributes)
      author = Author.where(username: attributes[:username]).first
      if author
        author
      else
        Author.create!(attributes.slice(:username, :email, :first_name, :last_name, :groups))
      end
    end
  end
end
