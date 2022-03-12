import sys
import json
stdout = sys.stdout

from download import download,setRateLimit

def processLine(line):
	try:
		decoded = json.loads(line)
	except Exception as e: stdout.write(json.dumps({'err': str(e)}))
	else:
		func = decoded.get('f')
		nonce = decoded.get('o')
		data = decoded.get('d')

		# execute function
		if not func:                 result = download(data)
		elif func == "setRateLimit": result = setRateLimit(data)
		else: result = "ERR:KEYUNDEFINED"

		# write return data
		if not result: result = False
		returnData = {'o': nonce}
		if type(result) == str and result.startswith("ERR:"):
			returnData['e'] = result
		else: returnData['d'] = result
		stdout.write(json.dumps(returnData))
		stdout.write("\n")
		stdout.flush()
