'use strict';

import * as express from 'express';
import * as console from 'console';
import * as HttpStatus from 'http-status';

export const errors = {
    error400: (req, res, next) => {
        if (!res) {
            console.error('res is undefined');
            return;
        }
        response(res, HttpStatus.NOT_FOUND);
    },
    error500: (err, req, res, next) => {
        response(res, err.message.parseInt || HttpStatus.INTERNAL_SERVER_ERROR);
    }
};

export function response(res: express.Response, code: number, json?: any) {
    if (json) {
        res.status(code).json(json);
    } else {
        res.status(code).json({
            msg: HttpStatus[code]
        });
    }
}
