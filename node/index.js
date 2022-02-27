const readline = require('readline')
const pidusage = require('pidusage')
const { finished } = require('stream/promises')
const stdinInterface = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
})
const stdout = process.stdout
const processing = {
    'getProcInfo':async data=>{
        return await pidusage(data.pid)
    }
}
const sleep = ms => new Promise(r => setTimeout(r, ms))

stdinInterface.on('line',async line=>{
    let request
    try {
        request = JSON.parse(line)
    } catch (err) {
        return stdout.write('ERR:PARSEFAIL:'+err)
    }
    let nonce = request.o,
        data  = request.d,
        key   = request.f
    let func = processing[key]
    if (func == undefined) {
        return stdout.write(JSON.stringify({'o':nonce,'e':'ERR:KEYUNDEFINED'}))
    }
    let result
    try {
        result = await func(data)
    } catch (err) {
        return stdout.write(JSON.stringify({'o':nonce,'e':'ERR:FUNC:'+err}))
    }
    stdout.write(JSON.stringify({'o':nonce,'d':result}))
})

