require! {
  express
  \body-parser
  request
  \macaroons.js
  \path-to-regexp
  sqlite3
}

const ARBITER_TOKEN = process.env.ARBITER_TOKEN
const HOSTNAME = process.env.HOSTNAME
const PORT = process.env.PORT or 8080

unless ARBITER_TOKEN?
  throw new Error 'Arbiter token undefined'

unless HOSTNAME?
  throw new Error 'Hostname undefined'

db = new sqlite3.Database 'store.db'
db.serialize !->
  db.run "CREATE TABLE IF NOT EXISTS entries (
    id INTEGER PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    value TEXT NOT NULL
  )"

# Register with arbiter and get secret
#err, res, secret <-! request.post do
#  url: 'http://arbiter:8080/register'
#  form: token: ARBITER_TOKEN

#if err? then throw err

#secret = new Buffer secret, \base64

app = express!

  #..enable 'trust proxy'

  ..use express.static 'static'

  ..use body-parser.urlencoded extended: false strict: false

  ..use (req, res, next) !->
    res.header 'Access-Control-Allow-Origin' \*
    res.header 'Content-Type' \application/json
    next!

  #..get '/' (req, res) !-> res.send '// TODO: Disable UI for containers with no UI'

  ..get '/status' (req, res) !-> res.send \active

  #..post '/*' (req, res, next) !->
  #  unless req.body.macaroon?
  #    res.status 400 .send 'Missing macaroon'
  #    return

  #  #console.log "Host: #{req.headers.host}, IP: #{req.ip}"
  #  #console.log "Macaroon:" req.body.macaroon

  #  macaroon = macaroons.MacaroonsBuilder.deserialize req.body.macaroon
  #  delete req.body.macaroon

  #  #console.log "Macaroon:" macaroon.inspect!

  #  req.macaroon = new macaroons.MacaroonsVerifier macaroon
  #    # TODO: Verify expiry here too
  #    ..satisfy-exact "target = #HOSTNAME"

  #  next!

  #..post '/*' do ->
  #  verify-path = do ->
  #    prefix = /path = .*/
  #    prefix-len = 'path = '.length

  #    (path, caveat) -->
  #      return false unless prefix.test caveat
  #      caveat
  #        |> (.substring prefix-len)
  #        |> (.trim!)
  #        # TODO: Catch potential JSON.parse exception
  #        |> JSON.parse
  #        |> path-to-regexp
  #        |> (.test path)

  #  (req, res, next) !->
  #    req.macaroon
  #      ..satisfy-general verify-path req.path
  #      # TODO: Verify granularity etc here (or in driver)?

  #    unless req.macaroon.is-valid secret
  #      res.status 403 .send 'Invalid macaroon'
  #      return

  #    next!

  ..get \/ (req, res) !->
    console.log req.query
    unless req.query.value?
      res.status 400 .send 'Missing data'
      return

    db.serialize !->
      <-! db.run 'INSERT INTO entries VALUES (NULL, NULL, ?)' req.query.value
      res.send ''

  ..listen PORT
