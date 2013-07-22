
envConfig = process.env

http = require('http')
httpProxy = require('http-proxy')
url = require('url')
ecstatic = require('ecstatic')

staticd = ecstatic(envConfig.STYLEGUIDE + '/out')

target_api = url.parse(envConfig.API)
console.log('API TARGET', target_api)

proxy = new httpProxy.RoutingProxy( )

debug_echo = (req, res) ->
  req.debug = false
  if req.url.indexOf('/debug/') is 0
    req.debug = true
    req.original_url = req.url
    req.re_request_path = req.url.split('/debug/')[1]
    req.url = '/api/echo'
    orig = url.parse(req.original_url)
    if orig.search
      req.url += orig.search + '&'
    else
      req.url += '?'
    req.url += "original_url=" + encodeURIComponent(req.original_url)
    console.log('NEW URL', req.url)
  return

fill_response = (req, res) ->
  if req.debug
    console.log('DEBUG FILL RESPONSE', res)
  return

server = http.createServer((req, res) ->
  console.log('request', req.url)
  debug_echo(req, res)
  r = /^\/api(\/.*$)/g
  if req.url.indexOf('/api/') is 0
    #req.url = req.url.split(r)[1]
    console.log('URL', req.url)
    console.log('bounce to API', target_api)
    target = 
      host: target_api.hostname,
      port: Number(target_api.port || 80)

    proxy.proxyRequest(req, res, target)
    proxy.on('body', (data) ->
      console.log('DEBUGGING data from new URL', data)
    )
  else
    return staticd(req, res)
  fill_response(req, res)
)

console.log('listening on', envConfig.PORT)
server.listen(envConfig.PORT)
