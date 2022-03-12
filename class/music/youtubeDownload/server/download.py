from typing_extensions import final
from yt_dlp import YoutubeDL

class Timeout(Exception): pass

def downloadHook(data):
	if data['status'] == "downloading" and data['elapsed'] >= 60:
		raise Timeout
downloadHooks = [downloadHook]

rateLimit = None

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
		'continuedl': True,
		'progress_hooks': downloadHooks
	}
	if rateLimit: ydl_opts['ratelimit'] = rateLimit
	try:
		with YoutubeDL(ydl_opts) as ydl:
			return ydl.extract_info(url,download=(not noDownload))
	except Timeout: return "ERR:TIMEOUT"
	except Exception as e: return "ERR:"+str(e)

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
