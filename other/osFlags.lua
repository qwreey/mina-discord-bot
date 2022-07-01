
-- 이 코드는 리눅스 배포판을 구별하기 위해 사용됩니다
-- 특히 우분투의 경우 버전에 따라 glibc 같은게 달라지기도 해
-- 다른 컴파일된 바이너리 파일을 사용할 수 있어서 나눠줘야 할 필요가
-- 있었어서 이 스크립트로 구분을 하고, 이것으로 올바른 바이너리를
-- 찾아 모든 명령을 수행합니다

local fs = require "fs";
local osFile = fs.readFileSync("/etc/os-release").."\n";

local OsId = osFile:match"ID=\"?(.-)\"?\n";
local versionId = osFile:match"VERSION_ID=\"?(.-)\"?\n";

return io.write(("%s_%s"):format(OsId,versionId));
