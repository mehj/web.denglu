express = require 'express'
DynamoDBStore = require('connect-dynamodb') express
{domain, secretKey} = require 'app-config.json'

app = express()

app.configure ->
    app.use express.favicon('public/favicon.ico')
    app.use express.logger('dev')
    app.use express.bodyParser()
    app.use express.cookieParser()
    app.use express.session(
        store: new DynamoDBStore(table: domain + '-session')
        cookie: {maxAge: 365 * 24 * 60 * 60 * 1000}
        secret: secretKey)
    app.use app.router
    app.use express.static(path.join(__dirname, 'public'))

app.configure 'development', ->
  app.use express.errorHandler()

exports.app = require('./routes') app