local uv = uv or require("uv");
for _,path in pairs({
    "./app";
    "./bin";
    "./commands";
    "./deps";
    "./libs";
}) do
    local fse = uv.new_fs_event();
    uv.fs_event_start(fse,path,{
        recursive = true;
    },function (err,fname,status)
        if(err) then
            logger.debug("Error ", err);
        else
            logger.infof("Some file was changed : %s", fname);
            if _G.livereloadEnabled then
                logger.infof("Try to do live reloading . . .");
                os.exit(require("app.exitCodes").reload);
            end
        end
    end);
end
