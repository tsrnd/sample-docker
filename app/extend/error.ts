/**
 * HTTP Error
 */
class HTTPError extends Error {
    status: number

    constructor() {
        super()
    }
}

/**
 * System Error
 */
class SystemError extends Error {
    code: string
    syscall: string

    constructor() {
        super()
    }
}
