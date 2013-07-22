
envConfig = process.env

http = require('http')
httpProxy = require('http-proxy')
url = require('url')
ecstatic = require('ecstatic')

staticd = ecstatic(envConfig.STYLEGUIDE + '/out')

target_api = url.parse(envConfig.API)
console.log('API TARGET', target_api)

proxy = new httpProxy.RoutingProxy( )

server = http.createServer( (req, res) ->
  console.log('request', req.url, req)
  r = /^\/api(\/.*$)/g
  if req.url.indexOf('/api/') is 0
    req.url = req.url.split(r)[1]
    console.log('URL', req.url)
    console.log('bounce to API', target_api)
    target = 
      host: target_api.hostname,
      port: Number(target_api.port || 80)

    proxy.proxyRequest(req, res, target)
  else
    return staticd(req, res)
)

console.log('listening on', envConfig.PORT)
server.listen(envConfig.PORT)
