"use strict";

class HTTPError extends Error {
    public status: number;

    constructor(status: number) {
        super();
        this.status = status;
        this.stack = new Error().stack;
    }
}

class SystemError extends Error {
    public code: string;
    public syscall: string;

    constructor(code: string, syscall: string) {
        super();
        this.code = code;
        this.syscall = syscall;
        this.stack = new Error().stack;
    }
}
