module Spree
  module ContactUs
    class Contact
      include ActiveModel::Conversion
      include ActiveModel::Validations

      attr_accessor :email, :message, :name, :subject

      EMAIL_REGEX = /\A
        [^\s@]+ # non-at-sign characters, at least one
          @     # at-sign
        [^\s.@] # non-at-sign and non-period character
        [^\s@]* # 0 or more non-at-sign characters, accepts any number of periods
         \.     # period
        [^\s@]* # 0 or more non-at-sign characters, accepts any number of periods
        [^\s.@] # non-at-sign and non-period character
      \z/x

      validates :email, format: { with: EMAIL_REGEX }, presence: true
      validates :message, presence: true
      validates :name, presence: { if: proc { SolidusContactUs::Config.require_name } }
      validates :subject, presence: { if: proc { SolidusContactUs::Config.require_subject } }

      def initialize(attributes = {})
        [:email, :message, :name, :subject].each do |attribute|
          send("#{attribute}=", attributes[attribute]) if attributes && attributes.key?(attribute)
        end
      end

      def save
        if valid?
          Spree::ContactUs::ContactMailer.contact_email(self).deliver_now
          return true
        end
        false
      end

      def persisted?
        false
      end
    end
  end
end
