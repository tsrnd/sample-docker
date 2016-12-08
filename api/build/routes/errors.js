'use strict';
const console = require("console");
const HttpStatus = require("http-status");
module.exports = {
    error404: (req, res, next) => {
        if (!res) {
            console.error('res is undefined');
            return;
        }
        const code = HttpStatus.NOT_FOUND;
        const msg = HttpStatus[code];
        res.status(code).json({ error: msg });
    },
    error500: (err, req, res, next) => {
        const code = err.message.parseInt || HttpStatus.INTERNAL_SERVER_ERROR;
        const msg = HttpStatus[code];
        res.status(code).json({ error: msg });
    }
};
//# sourceMappingURL=errors.js.map