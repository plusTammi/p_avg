function [ avgs] = average( data,triggers,avg_start,avg_end )
%data=nxm matriisi
%triggers= ne pisteet, joiden ympäriltä tehdään keskiarvo
%avg_start=triggeristä se määrä, kuinka paljon siirrytään taaksepäin
%avg_end=triggeristä se määrä, kuinka paljon siirrytään eteenpäin

%avgs=nx(avg_start+avg_end) matriisi, jossa kanavakohtaiset keskiarvot
    mask=avg_start:avg_end;
    avg_lenght=length(mask);
    chn_length=size(data,1);
    
    mask=repmat(mask,length(triggers),1);
    trigs=repmat(triggers.',1,size(mask,2)); 
    length(triggers)
    size(mask)
    size(trigs)
    mask=int32(trigs)+int32(mask);
    mask=mask(sum(mask<0,2)==0,:);
    mask=mask(sum(mask>length(data),2)==0,:);
    trig_length=size(mask,1);

    avgs=reshape(data(:,mask),[chn_length,trig_length,avg_lenght]);
    avgs=reshape(mean(avgs,2),[chn_length,avg_lenght]);
    avgs=avgs-repmat(avgs(:,1),1,avg_lenght);
end

