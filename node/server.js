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
var server = require('http').createServer(app);
log.info("Started NodeJS Server");

var port = 3000;
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
