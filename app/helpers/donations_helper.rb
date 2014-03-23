module DonationsHelper
  def anonymize_email(email)
    return if email.blank?
    email_parts = email.split('@', 2)
    "#{email_parts[0][0]}****#{email_parts[0][-1]}@#{email_parts[1]}" if email.present?
  end
end
