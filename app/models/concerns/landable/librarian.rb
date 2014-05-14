module Landable
  # modules
  module Librarian
    # The original name for this module was Landable::JamesCole, but Isaac said 'no.'
    # if this name confuses you, go watch "12 Monkeys" you class-less savage.
    # Wait, where were you in 95? Prison? The womb? Ohmygawd, that was a great film.

    # extensions
    extend ActiveSupport::Concern

    # includes
    included do
    end

    # validations
    
    # standard methods
    def deactivate
      self.update_attribute(:deleted_at, Time.now)
    end

    # custom methods
    def nuke!
      self.destroy
    end

    def reactivate
      self.update_attribute(:deleted_at, nil)
    end
    
    # end
  end

  # Live Long the Army of the 12 Monkeys!
  # end
end
