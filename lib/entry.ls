require! <[pug]>

TERM_OPTS =
  debug: yes
  focus: no
  fontSize: 12
  fontFamily: 'monospace, courier-new, courier'

LOAD_RESOURCE = (url, ready-cb) ->
  xhttp = new XMLHttpRequest!
  xhttp.onreadystatechange = ->
    return ready-cb null, @responseText if @readyState is 4 and @status is 200
    return ready-cb "failed to read from #{url}, status: #{@status}"
  xhttp.open \GET, url, yes
  xhttp.send!

LOAD_JAVASCRIPT = (url, location, ready-callback) ->
  now = new Date! - 0
  script = document.createElement \script
  script.src = "#{url}?&_timestamp=#{now}"
  script.onload = ready-callback
  script.onreadystatechange = ready-callback
  location.append script

GET_PROPERTIES = (c) ->
  xs = [ (k.toUpperCase!) for k, v of c.properties when v]
  return "[#{xs.join ', '}]"

SIMPLE_ID = (uuid) ->
  return ((uuid.split '-').join '').to-lower-case!

DATA_UPDATED = (characteristic, evt) ->
  {uuid} = characteristic-map
  {target} = evt
  {value} = target
  xs = [ (value.getUint8 i) for i from 0 to (value.byteLength - 1) ]
  data = new Buffer xs
  temperature = -46.85 + 175.72 / 65536.0 * data.readUInt16LE 0
  humidity = -6.0 + 125.0 / 65536.0 * ((data.readUInt16LE 2) .&. ~0x0003)
  return console.log "DATA_UPDATED: temperature=#{temperature.to-fixed 2}, humidity=#{humidity.to-fixed 2}, (data: #{data.to-string 'hex'})"


SERVICE_UUID = \f000aa20-0451-4000-b000-000000000000
HUMIDITY_CONFIG_UUID = \f000aa2204514000b000000000000000
HUMIDITY_DATA_UUID = \f000aa2104514000b000000000000000

RUN_TEST = ->
  opts =
    acceptAllDevices: yes
    optionalServices: [SERVICE_UUID]
  console.log "scanning opts: #{JSON.stringify opts}"
  p = navigator.bluetooth.requestDevice opts
      .then (device) ->
        console.log "found device: #{device.name}, and try to connect ..."
        return device.gatt.connect!
      .then (server) ->
        console.log "connected, and try to discover services ..."
        return server.getPrimaryServices!
      .then (services) ->
        console.log "discovered #{services.length} services, then discover characteristics ..."
        return if services.length <= 0
        return services[0].getCharacteristics!
      .then (characteristics) ->
        console.log "discovered #{characteristics.length} characteristics"
        for let c, i in characteristics
          console.log "chars[#{i}]: #{c.uuid} => #{GET_PROPERTIES c}"
        window.characteristic-map = {[(SIMPLE_ID c.uuid), c] for c in characteristics}
        data-c = characteristic-map[HUMIDITY_DATA_UUID]
        return data-c.startNotifications!
      .then (data-c) ->
        data-c.addEventListener \characteristicvaluechanged, (evt) -> return DATA_UPDATED data-c, evt
        console.log "#{HUMIDITY_DATA_UUID} notification is started ..."
        {characteristic-map} = window
        enabled = Uint8Array.of 1
        data-config = characteristic-map[HUMIDITY_CONFIG_UUID]
        return data-config.writeValue enabled
      .then (data-config) ->
        console.log "#{HUMIDITY_CONFIG_UUID} is written with 1 to enable SensorTag notification ..."
      .catch (err) -> console.log "failed. error => #{err}"
  return


now = new Date! - 0
document.body.innerHTML = "Loading body template and compile ..."
(load-err1, template) <- LOAD_RESOURCE "body.jade?_timestamp=#{now}"
return document.body.innerHTML = "Failed to load body.jade!! #{load-err1}" if load-err1?
text = pug.render template, {}
console.log "template: \n#{template}"
console.log "body: \n#{text}"

window.run_test = RUN_TEST
document.body.innerHTML = text

CONSOLE_LOG_VIEWER_URL = 'http://markknol.github.io/console-log-viewer/console-log-viewer.js?align=bottom'
console.log "loading console-log-viewer from #{CONSOLE_LOG_VIEWER_URL} ..."
<- LOAD_JAVASCRIPT CONSOLE_LOG_VIEWER_URL, document.body
console.log "console-log-viewer ready!!"
