require "./base"

module TandaCLI
  module Error
    class FutureDate < Error::Base
      def initialize(date : ::Time) : Nil
        super("Date is in the future!", "#{Utils::Time.pretty_date(date)} hasn't happened yet.")
      end
    end
  end
end
