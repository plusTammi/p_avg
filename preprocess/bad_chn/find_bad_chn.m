function [bads] = find_bad_chn(data,len_beats)
    most_common=mode(len_beats);
    bads=abs(len_beats-most_common)>5;
    
    mags=data(1:3:99,:);
    r=corrcoef(mags.');
    bads(1:3:99,:)=bads(1:3:99,:)&(mean(r)<0.95).';
end

