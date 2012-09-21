
###
Module dependencies.
###


express = require("express")
routes = require("./routes")
http = require("http");
path = require("path")
app = express()
app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("KJGUIIUGU3425KZGU")
  app.use express.session()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()


#Routes
app.get "/", routes.index

db = require('../models/travel')
require('./controllers/travel')(app, db)

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

