'use strict';
const console = require("console");
const HttpStatus = require("http-status");
exports.errors = {
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
function response(res, code, json) {
    if (json) {
        res.status(code).json(json);
    }
    else {
        res.status(code).json({
            msg: HttpStatus[code]
        });
    }
}
exports.response = response;
