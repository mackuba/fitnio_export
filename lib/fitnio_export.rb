require 'mechanize'
require 'json'
require 'time'
require 'logger'

class FitnioExport
  class AuthenticationError < StandardError; end

  MILE_TO_KM = 1.609344

  SIGNIN_URL = "http://fitnio.com/signIn.htm"
  DATA_URL = "http://fitnio.com/mapData.htm"

  SPORT_TYPES = {
    'W' => 'Walking',
    'R' => 'Running',
    'B' => 'Biking'
  }

  GPX_HEADER = <<-HEADER
<?xml version="1.0" encoding="UTF-8"?>
<gpx
  version="1.1"
  creator="fitnio_export (http://github.com/jsuder/fitnio_export)"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns="http://www.topografix.com/GPX/1/1"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
  xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1">
<trk>
  HEADER

  GPX_FOOTER = <<-FOOTER
</trkseg>
</trk>
</gpx>
  FOOTER

  def initialize(email, password)
    @email = email
    @password = password
    @logger = Logger.new(STDOUT)
    @logger.formatter = lambda { |type, time, program, text| "#{time}: #{text}\n" }
    @browser = Mechanize.new
  end

  def start
    rows = get_activity_rows

    rows.each do |row|
      id = row['id']
      json = get_activity_json(id)

      date_row = row.search('td')[1]
      date_string = date_row.to_s.gsub(/<.*?>/, ' ').strip

      sprite = row.search('.gs-sprite')[0]
      type = sprite['class'][/me-(\w)/].split('-').last

      save_data_file(json, date_string, type)
    end

    log "Done."
  end


  private

  def log(text)
    @logger.info(text)
  end

  def get_activity_rows
    log "Downloading dashboard page..."

    page = @browser.post(SIGNIN_URL, :email => @email, :password => @password, :createAccount => false)

    if page.search('#me-data').length == 0
      raise AuthenticationError, "Incorrect email or password"
    end

    page.search('.session-row')
  end

  def get_activity_json(id)
    log "Downloading activity #{id}..."

    json_page = @browser.get(DATA_URL, :key => id)
    json = json_page.body.gsub(%r(^//), '')

    JSON.parse(json)
  end

  def save_data_file(json, date_string, type)
    start_date = Time.parse(date_string)
    filename = "fitnio-#{start_date.strftime('%Y-%m-%d-%H%M')}.gpx"
    log "Saving #{filename}..."

    File.open(filename, "w") do |file|
      file.write GPX_HEADER
      file.puts "<name>#{SPORT_TYPES[type]} #{date_string}</name>"
      file.puts "<time>#{start_date.utc.xmlschema}</time>"
      file.puts "<trkseg>"

      json['points'].each do |point|
        lat = sprintf("%.9f", point['latitude'])
        long = sprintf("%.9f", point['longitude'])

        # fitnio seems to return incorrect altitude (it shows ~77 m where Runkeeper shows ~230m),
        # but it doesn't matter since Runkeeper finds the correct values by itself
        alt = sprintf("%.2f", point['altitude'] * MILE_TO_KM * 1000)

        time = (start_date + point['timeOffset'] / 1000.0).utc.xmlschema(3)

        file.puts %(<trkpt lat="#{lat}" lon="#{long}"><ele>#{alt}</ele><time>#{time}</time></trkpt>)
      end

      file.write GPX_FOOTER
    end
  end
end
