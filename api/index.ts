'use strict';

import * as express from 'express';
import * as logger from 'morgan';
import * as cookieParser from 'cookie-parser';
import * as bodyParser from 'body-parser';
import * as console from 'console';
import * as http from 'http';
import {errors} from './extend';

const app = express();
const env = process.env.NODE_ENV;

env === 'production' && app.disable('verbose extend') || app.enable('verbose extend');

// routers
app.use('/v1', require('./routes/v1'));

// middlewares
(env === 'test') || app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));
app.use(cookieParser());

app.use([errors.error400, errors.error500]);

const port = process.env.PORT || '3000';
app.set('port', port);

const server = http.createServer(app);
server.listen(port);

server.on('error', (err: NodeJS.ErrnoException) => {
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
