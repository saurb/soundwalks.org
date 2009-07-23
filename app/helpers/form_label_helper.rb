module FormLabelHelper
  def label_with_errors user, attribute, label
    error_text = nil

    user.errors.each do |attr, error|
      if attr.eql? attribute
        if (attr.eql? 'secret')
          error_text = 'Incorrect'
        else
          error_text = error
        end
        break
      end
    end

    label_text = label
    label_text += "<br /><span class='error'>#{error_text}</span>" if error_text

    return label_text
  end
end