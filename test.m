path='m1.txt';
fileID = fopen(path);
paths = textscan(fileID,'%s','delimiter','\n');
fclose(fileID);
cur=51
diary('errors.txt')
diary off
for i=paths{1}(cur:end)'
    try
        file_loc=char(i);
        
        fprintf('%d %str\n',cur,file_loc)
        p=Preprocess(char(file_loc));
        p.d.load({'fif'});
        p.d.cur=p.d.raw;
        p.qrs_trig;
        p.compute_bad_chn;
        p.compute_ssp;
        p.compute_baseline_spline(-400);
        p.compute_averages(-300,500);
        p.d.save
        cur=cur+1;
    catch e
        diary on
        fprintf('%d %s\n %s: %s\n',cur,char(i),e.identifier,e.message);
        for i=1:size(e.stack,1)
            temp=e.stack(i);
            fprintf('...%s, %s, %d\n',temp.file(end-30:end),temp.name,temp.line);
        end
        fprintf('\n',temp.file(end-30:end),temp.name,temp.line);
        diary off
        break
        cur=cur+1;
    end
end
diary on
fprintf('END\n\n\n\n\n',cur,char(i),e.identifier,e.message);
diary off