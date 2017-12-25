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

RUN_TEST = ->
  console.log "yes, test02 is running ..."
  p = navigator.bluetooth.requestDevice {acceptAllDevices: yes}
      .then (device) -> console.log "found device: #{device.name}"
      .catch (err) -> console.log "failed scan device: #{err}"
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
