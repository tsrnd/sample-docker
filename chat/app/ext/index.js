'use strict';

const console = require("console");
const HttpStatus = require("http-status");

function rep(res, code, json) {
    if (json) {
        res.status(code).json(json);
    } else {
        res.status(code).json({
            msg: HttpStatus[code]
        });
    }
};

exports.rep = rep;

exports.error = function error(code) {
    return (req, res, next) => {
        switch (code) {
            case HttpStatus.NOT_FOUND:
                if (!res) {
                    console.error('res is undefined');
                    return;
                }
                rep(res, HttpStatus.NOT_FOUND);
                break;
            case HttpStatus.INTERNAL_SERVER_ERROR:
                rep(res, err.message.parseInt || HttpStatus.INTERNAL_SERVER_ERROR);
                break;
            default:
                return null;
        }
    }
}
