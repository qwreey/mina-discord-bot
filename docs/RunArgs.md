# voice.useStream
Enable stream to play music

# voice.ytdl
Use youtube-dlp instead youtube-dl for download audios

# voice.no-download-server
Don't make youtube-dlp server with python

# voice.stderr-tty
use tty instead pipe for python (youtube-dlp)

# voice.download-rate-limit=INT
set download rate limit

# voice.disable-server-side-postprocessor

# env.httpHeartbeat
Enable http heartbeat mode  

# env.testing || test || testing
Enable testing mode

# "voice.disabled=STR"
disable music feature, the STR is reason of why this feature can't be use
if STR have space or other rule-breaker char, you need to escape all with "
* STR is json object, you can add content, embed, and more

# "os.flag=STR"
set os flag, this will used for searching bin files
