function [vob] = readVobFile(fname)
    vob = '';
    fid = fopen(fname);
    tline = fgetl(fid);
    while ischar(tline)
        ind = sscanf(tline, '%d:');
        ind = ind(1);
        if ind == 81
            fprintf(1,'......');
        end
        if ind>0
            fprintf(1,'%s \n',tline);
            a = strfind(tline,':')+1;
            vob{ind} =tline(a:end);
        end
        tline = fgetl(fid);
    end
    fclose(fid);
end