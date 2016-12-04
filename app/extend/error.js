"use strict";
class HTTPError extends Error {
    constructor(status) {
        super();
        this.status = status;
        this.stack = new Error().stack;
    }
}
class SystemError extends Error {
    constructor(code, syscall) {
        super();
        this.code = code;
        this.syscall = syscall;
        this.stack = new Error().stack;
    }
}
//# sourceMappingURL=error.js.map