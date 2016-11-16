var fs = require('fs');
var express = require("express");

var Log = require("log");
log = new Log("debug");

// app
var app = new express();
app.use(express.static(__dirname + '/public'));

app.get("/", function(req, res) {
    res.redirect("index.html");
});

// server
var port = process.env.PORT || 3000;
var ssl = process.env.SSL;

if (ssl == 'true' || ssl == '1') {
    var https = require('https');
    var server = https.createServer({
        key: fs.readFileSync(process.env.SSL_KEY),
        cert: fs.readFileSync(process.env.SSL_CER)
    }, app);
    log.info("Start HTTPS");
} else {
    var server = require('http').createServer(app);
    log.info("Start HTTP");
}

server.listen(port, function() {
    log.info("Listening port %s", port);
});

// stream
var io = require("socket.io")(server);
var ss = require("socket.io-stream");

io.on('connection', function(socket) {
    log.info("New client");
    ss(socket).on('stream', function(data) {
        socket.broadcast.emit("stream", data);
    });
});
