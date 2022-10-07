# VOICE

## voice.useStream
Enable stream to play music

## voice.ytdl
Use youtube-dlp instead youtube-dl for download audios

## voice.no-download-server
Don't make youtube-dlp server with python

## voice.stderr-tty
use tty instead pipe for python (youtube-dlp)

## voice.download-rate-limit=INT
set download rate limit

## voice.disable-server-side-postprocessor

## "voice.disabled=STR"
disable music feature, STR is reason why disabled
* STR is json object, you can add content, embed, and more

# ENV

## env.httpHeartbeat
Enable http heartbeat mode  

## env.testing || test || testing
Enable testing mode

## env.livereload || livereload || reload
Enable livereload mode, kill process and reload when file changed

## env.disable_terminal || disable_terminal
Disable terminal input mode

## "os.flag=STR"
set os flag, this will used for searching bin files

## "execute=FILE"
execute lua file on main thread (require)  

