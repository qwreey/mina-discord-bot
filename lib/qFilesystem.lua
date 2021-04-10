local Module = {}

function Split(Str, Pattern)
	local Pattern = Pattern or "%s"
	local ReturnTable = {}
	for Part in string.gmatch(Str, "([^"..Pattern.."]+)") do
		table.insert(ReturnTable, Part)
	end
	return ReturnTable
end

--// 하위 파일들 얻기(nt 계열 os 전용) => table
function Module:GetFiles(StringDir,FnMode)
	local FilesFn = io.popen(([[dir "%s" /b /a-d]]):format(StringDir)):lines()
	if FnMode then
		return FilesFn
	end
	
	local Files = {}
	for v in FilesFn do
		Files[#Files+1] = v
	end
	return Files
end

--// 하위 폴더들 얻기(nt 계열 os 전용) => table
function Module:GetFolders(StringDir,FnMode)
	local FilesFn = io.popen(([[dir "%s" /b /ad]]):format(StringDir)):lines()
	if FnMode then
		return FilesFn
	end
	
	local Files = {}
	for v in FilesFn do
		Files[#Files+1] = v
	end
	return Files
end

--// 하위 파일/폴더들 얻기(nt 계열 os 전용) => table
function Module:GetChildren(StringDir,FnMode)
	local FilesFn = io.popen(([[dir "%s" /b]]):format(StringDir)):lines()
	if FnMode then
		return FilesFn
	end
	
	local Files = {}
	for v in FilesFn do
		Files[#Files+1] = v
	end
	return Files
end

--// 상위 디렉터리 얻기 => Dir:string
function Module:GetParent(StringDir)
	local SplitDir = Split(StringDir,"/")
	local FileNameLen = #SplitDir[#SplitDir]
	local StringDir = string.sub(StringDir,1,#StringDir-FileNameLen-1)
	return StringDir
end

--// 파일의 확장자 얻기 => Ext:string
function Module:GetExtension(StringDir)
	if not string.find(StringDir,"%.") then
		return ""
	end
	local SplitDir = Split(StringDir,"%.")
	return SplitDir[#SplitDir]
end

--// 파일/폴더 지우기 => nil
function Module:Remove(StringDir)
	os.remove(StringDir)
	return nil
end

--// 파일/폴더 옴기기 => Dir:string
function Module:Move(StringDir, ToDir)
	local FileName do
		local SplitDir = Split(StringDir,"/")
		FileName = SplitDir[#SplitDir]
	end
	
	local ToDir = ToDir .. "/" .. FileName
	os.rename(StringDir,ToDir)
	
	return ToDir
end

--// 디렉터리가(파일) 존재 하는지 확인
function Module:IsExistsDir(Dir)
	local File = io.open(Dir, 'rb')
	if File then
		File:close()
	end
	return File ~= nil
end

--// 해당 디렉터리에 해당 파일이 존재하는지 확인
function Module:IsExists(Dir,FileName)
	local File = io.open(Dir .. "/" .. FileName, 'rb')
	if File then
		File:close()
	end
	return File ~= nil
end

--// 파일/폴더 옴기기고 이름 바꾸기 => Dir:string
function Module:MoveAndRename(StringDir, ToDir, Name)
	local ToDir = ToDir .. "/" .. Name
	os.rename(StringDir,ToDir)
	
	return ToDir
end

--// 이름 바꾸기(파일의 경우 확장자 포함) => Dir:string
function Module:Rename(StringDir,Name)
	local ToDir = Module:GetParent(StringDir) .. "/" .. Name
	os.rename(StringDir,ToDir)
	return ToDir
end

--// 파일 만들기
function Module:MakeFile(Dir,FileName,Ext)
	os.execute(('echo "" > "luafilesystemtmpfileI.txt"'))
	Module:MoveAndRename("luafilesystemtmpfileI.txt",Dir,FileName .. "." .. Ext)
end

return Module