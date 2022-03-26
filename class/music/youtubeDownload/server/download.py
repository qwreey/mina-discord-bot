from yt_dlp import YoutubeDL
class Timeout(Exception): pass
rateLimit = None

# download hook
def downloadHook(data):
	if data['status'] == "downloading" and data['elapsed'] >= 60:
		raise Timeout
downloadHooks = [downloadHook]

# post process
postprocessorArgs = {
	# default field will used for ffmpeg process
	'default':['-filter:a','loudnorm'] # ffmpeg loadnorm filter
}
postprocessEnabled = True

def handleYtdlp(url,noDownload,file):
	global rateLimit
	ydl_opts = {
		'format': 'bestaudio',
		'noprogress': True,
		'quiet': True,
		'no_warnings': True,
		'simulate': noDownload,
		'cachedir': 'data/youtubeCache',
		'outtmpl': file,
		'continuedl': True, # download continue for last session
		'progress_hooks': downloadHooks, # download progress hooks
	}
	if rateLimit: ydl_opts['ratelimit'] = rateLimit
	if postprocessEnabled: ydl_opts['postprocessor_args'] = postprocessorArgs
	try:
		with YoutubeDL(ydl_opts) as ydl:
			return ydl.extract_info(url,download=(not noDownload))
	except Timeout: return "ERR:TIMEOUT"
	except Exception as e: return "ERR:"+type(e).__name__+":"+str(e)

def download(data):
	return handleYtdlp(
		data.get('url'),
		data.get('noDownload') or False,
		data.get('file')
	)

def setRateLimit(newRateLimit):
	global rateLimit
	this = None
	try:
		this = int(newRateLimit)
	except: pass
	finally:
		rateLimit = this

def setBuiltinPostProcessorEnabled(enabled):
	global postprocessEnabled
	postprocessEnabled = enabled
