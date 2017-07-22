path='m1.txt';
fileID = fopen(path);
paths = textscan(fileID,'%s','delimiter','\n');
fclose(fileID);
cur=1;
cur_c=cur;
diary('errors.txt')
diary off
paths=paths{:}(cur:cur+2)';

for i=paths
    try
        tic
        file_loc=char(i);
        fprintf('%d %s\n',cur,file_loc)
        p=Preprocess(file_loc);
        p.d.remove
        p=Preprocess(file_loc);
        p.d.load({'fif'});
        p.d.cur=p.d.raw;
        p.qrs_trig();
        p.compute_bad_chn();
        p.compute_ssp();
        p.compute_baseline_spline(-400);
        p.found_beats(p.d.qrs_triggers)
        p.compute_averages(-300,500);
        p.d.save()
        cur=cur+1;
        toc
    catch e
        diary on
        fprintf('%d %s\n %s: %s\n',cur,char(i),e.identifier,e.message);
        for i=1:size(e.stack,1)
            temp=e.stack(i);
            fprintf('...%s, %s, %d\n',temp.file(end-30:end),temp.name,temp.line);
        end
        fprintf('\n',temp.file(end-30:end),temp.name,temp.line);
        diary off
        cur=cur+1;
        error e
    end
end

c=Choosing(paths);
c.load_qrs_avgs()
c.choose
c.save_borders

for i=paths
    try
        tic
        file_loc=char(i);
        fprintf('%d %s\n',cur,file_loc)
        p=Preprocess(file_loc);
        p.d.load({'cur','bad_chn','qrs_triggers','borders'});
        p.p_trig()
        p_rad=round((p.d.borders(2)-p.d.borders(1))/2);
        p.found_beats(p.d.p_triggers,-round(p_rad),-round(p_rad))
        p.compute_p_averages()
        p.d.save({'p_triggers','p_avgs','good_beats'})
        cur=cur+1;
        toc
    catch e
        diary on
        fprintf('%d %s\n %s: %s\n',cur,char(i),e.identifier,e.message);
        for i=1:size(e.stack,1)
            temp=e.stack(i);
            fprintf('...%s, %s, %d\n',temp.file(end-30:end),temp.name,temp.line);
        end
        fprintf('\n',temp.file(end-30:end),temp.name,temp.line);
        diary off
        cur=cur+1;
    end
end
diary on
fprintf('END\n\n\n\n\n');
diary off