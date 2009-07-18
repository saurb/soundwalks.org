module SoundwalksHelper
  def label_with_errors soundwalk, attribute, label
    error_text = nil
 
    soundwalk.errors.each do |attr, error|
      if attr.eql? attribute
        error_text = error
        break
      end
    end
    
    label_text = label
    label_text += "<br /><span class='error'>#{error_text}</span>" if error_text
    
    return label_text
  end

end
