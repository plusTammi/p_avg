function [beats] = arrange_beats(triggers,data,mask_start,mask_end)
%MASK Summary of this function goes here
%   Detailed explanation goes here
    mask=mask_start:mask_end;
    mask=repmat(mask,length(triggers),1);

    trigs=repmat(triggers.',1,size(mask,2));
    mask=int32(trigs)+int32(mask);
    mask=mask(sum(mask<0,2)==0,:);
    mask=mask(sum(mask>size(data,2),2)==0,:);
    
    chn_length=size(data,1);
    trig_length=size(mask,1);
    avg_lenght=size(mask,2);
    size(mask);
    size(data(:,mask));
    beats=reshape(data(:,mask),[chn_length,trig_length,avg_lenght]);
end

