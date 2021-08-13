local uv = uv or require("uv");
local fse = uv.new_fs_event();

for _,path in pairs({
    "./app";
    "./bin";
    "./commands";
    "./deps";
    "./libs";
}) do
    uv.fs_event_start(fse,path,{
        recursive = true;
    },function (err,fname,status)
        if(err) then
            iLogger.debug("Error ", err);
        else
            iLogger.infof("Some file was changed : %s", fname);
            iLogger.infof("Try to do live reloading . . .");
            os.exit(require("app.exitCodes").reload);
        end
    end);
end
