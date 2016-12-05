'use strict';
const express = require("express");
const path = require("path");
const favicon = require("serve-favicon");
const logger = require("morgan");
const cookieParser = require("cookie-parser");
const bodyParser = require("body-parser");
const console = require("console");
const http = require("http");
const sass = require("node-sass-middleware");
const app = express();
const env = process.env.NODE_ENV;
env === 'production' && app.disable('verbose errors') || app.enable('verbose errors');
app.set('views', path.join(__dirname, '../views'));
app.set('view engine', 'hbs');
app.use('/v1', require('./routes/v1'));
(env === 'test') || app.use(logger('dev'));
app.use(favicon(path.join(__dirname, '../public', 'images/favicon.ico')));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(sass({
    src: path.join(__dirname, 'public'),
    dest: path.join(__dirname, 'public'),
    indentedSyntax: true,
    sourceMap: true
}));
app.use(express.static(path.join(__dirname, 'public')));
const errors = require('./routes/errors');
app.use(errors.error404);
app.use(errors.error500);
const port = process.env.PORT || '3000';
app.set('port', port);
const server = http.createServer(app);
server.listen(port);
server.on('error', (err) => {
    if (err.syscall !== 'listen') {
        throw err;
    }
    const bind = typeof port === 'string'
        ? 'Pipe ' + port
        : 'Port ' + port;
    switch (err.code) {
        case 'EACCES':
            console.error(bind + ' requires elevated privileges');
            process.exit(1);
            break;
        case 'EADDRINUSE':
            console.error(bind + ' is already in use');
            process.exit(1);
            break;
        default:
            throw err;
    }
});
server.on('listening', () => {
    const addr = server.address();
    const bind = typeof addr === 'string'
        ? 'pipe ' + addr
        : 'port ' + addr.port;
    console.log('Listening on ' + bind);
});
//# sourceMappingURL=index.js.map