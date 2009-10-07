module LinksHelper
  def percentage_width input
    if input > 0
      return percentage_text(input)
    else
      return "0s"
    end
  end

  def percentage_text input
    return '%.2f' % (input * 100) + "%"
  end

  def check_nil input
    if !input.nil? && input
      return input
    else
      return 0
    end
  end
end