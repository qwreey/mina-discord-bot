const readline = require('readline')
const { finished } = require('stream/promises')
const stdinInterface = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
})
const stdout = process.stdout
const processing = {
    'getProcInfo':(data)=>{
        data.pid
    }
}

stdinInterface.on('line',(line)=>{
    let request = JSON.parse(line)
    let nonce = request.o,
        data  = request.d,
        key   = request.f
    let func = processing[key]
    if (func == undefined) {
        return stdout.write('ERR:KEYUNDEFINED')
    }
    let result
    try {
        result = func(o,data)
    } catch (err) {
        return stdout.write('ERR:FUNC:'+err)
    }
    stdout.write(JSON.stringify({'o':nonce,'d':result}))
})
