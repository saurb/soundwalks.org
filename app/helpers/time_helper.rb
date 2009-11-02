#----------------------------------------------------------------------#
# This is code originally from a Rails plugin. Need to remember which. #
#----------------------------------------------------------------------#

module TimeHelper
  mattr_accessor :time_class
  mattr_accessor :time_output
  
  self.time_class = Time
  self.time_output = {
    :today            => 'today',
    :yesterday        => 'yesterday',
    :tomorrow         => 'tomorrow',
    :initial_format   => '%b %d',
    :last_week_format => '%A',
    :time_format      => '%l:%M %p',
    :year_format      => ', %Y'
  }

  def relative_date(time, in_past = false)
    date  = time.to_date
    today = time_class.now.to_date
    if date == today
      time.respond_to?(:min) ? time.strftime(time_output[:time_format]) : time_output[:today]
    elsif date == (today - 1)
      time_output[:yesterday]
    elsif date == (today + 1)
      time_output[:tomorrow]
    elsif in_past && (today-6..today-2).include?(date)
      fmt = time_output[:last_week_format].dup
      time.strftime(time_output[:last_week_format])
    else
      fmt  = time_output[:initial_format].dup
      fmt << time_output[:year_format] unless date.year == today.year
      time.strftime(fmt)
    end
  end
  
  def relative_date_in_past(time)
    relative_date(time,true)
  end
  
  def relative_date_span(times)
    times = [times.first, times.last].collect!(&:to_date)
    times.sort!
    if times.first == times.last
      relative_date(times.first)
    else
      first = times.first; last = times.last; now = time_class.now
      returning [first.strftime('%b %d')] do |arr|
        arr << ", #{first.year}" unless first.year == last.year
        arr << ' - '
        arr << last.strftime('%b') << ' ' unless first.year == last.year && first.month == last.month
        arr << last.day
        arr << ", #{last.year}" unless first.year == last.year && last.year == now.year
      end.to_s
    end
  end
  
  def relative_time_span(times)
    times = times.collect {|time| time.utc}
    times = [times.first, times.last].collect!(&:to_time)
    times.sort!
    if times.first == times.last
      "#{prettier_time(times.first)} #{relative_date(times.first)} #{times.last.zone}"
    elsif times.first.to_date == times.last.to_date
        same_half = (times.first.hour/12 == times.last.hour/12)
        "#{prettier_time(times.first, !same_half)} - #{prettier_time(times.last)} #{relative_date(times.first)} #{times.last.zone}"

    else
      first = times.first; last = times.last; now = time_class.now        
      [prettier_time(first)].tap do |arr|
        arr << ' '
        arr << first.strftime('%b %d') << ' ' unless first.day == last.day && first.month == last.month
        arr << ", #{first.year}" unless first.year == last.year
        arr << ' - '
        arr << prettier_time(last)
        arr << ' '
        arr << last.strftime('%b %d') << ' ' unless first.day == last.day && first.month == last.month
        arr << ", #{last.year}" unless first.year == last.year && last.year == now.year
        arr << last.strftime('%Z')
      end.to_s
    end
  end
  
  def prettier_time(time, ampm=true)
    time.strftime("%I:%M:%S#{" %p" if ampm}").sub(/^0/, '')
  end
  
  def seconds_partial_hours(seconds)
    (seconds / 3600).to_i
  end
  
  def seconds_partial_minutes(seconds)
    ((seconds - (seconds_partial_hours(seconds) * 3600)) / 60).to_i
  end
  
  def seconds_partial_seconds(seconds)
    (seconds - (seconds_partial_hours(seconds) * 3600) - (seconds_partial_minutes(seconds) * 60)).to_i
  end
  
  def leading_zero(number)
    if number < 10
      "0#{number}"
    else
      number
    end
  end
  
  def duration_partial(seconds)
    time_string = ""
    
    hours = seconds_partial_hours seconds
    minutes = seconds_partial_minutes seconds
    seconds = seconds_partial_seconds seconds
    
    if hours && (minutes < 1) && (seconds < 1)
      time_string = "#{hours} hours"
    elsif (hours < 1) && minutes && seconds
      time_string = "#{minutes} minutes, #{seconds} seconds"
    elsif (hours < 1) && minutes && (seconds < 1)
      time_string = "#{minutes} minutes"
    elsif (hours < 1) && (minutes < 1) && seconds
      time_string = "#{seconds} seconds"
    else
      time_string = "#{hours}:#{leading_zero minutes}:#{leading_zero seconds}"
    end
    
    return time_string
  end
end
