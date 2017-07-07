function [triggers,len_beats] = qrs_triggering(data,fs,bad_chn)
    if nargin<3
        bad_chn=ones(size(data,1),1);
    end
    [rows,columns]=size(data(bad_chn,:));
    temp_mat=zeros(rows,columns);
    len_beats=zeros(rows,1);
    for row=1:rows
        [~,beats,~]=pan_tompkin(data(row,:),fs,0);
        len_beats(row)=size(beats,2);
        temp_mat(row,1:size(beats,2)) = beats;
    end
    triggers=median_of_same(temp_mat,len_beats);
end

function [triggers]=median_of_same(beats,len_beats)
    l=mode(len_beats);
    beats=beats(len_beats==l,1:l);
    triggers=median(beats);
end