module ConsentsHelper
  def consents_checkboxes
    checkboxes = Array.new
    Consent.get_formatted_consents.each do |consent_type|
      id = consent_type[:id]
      desc = consent_type[:short_description]
      mandatory = consent_type[:mandatory] ? '(required)' : ''
      checkbox = "<input type='checkbox' name='user[registration_consents][#{id}]'> #{desc} #{mandatory}<br/>"
      checkboxes.push(checkbox)
    end
    return checkboxes
  end
end
