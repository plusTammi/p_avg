function [ avgs] = average( data,triggers,avg_start,avg_end,corr )
%data=nxm matriisi
%triggers= ne pisteet, joiden ympäriltä tehdään keskiarvo
%avg_start=triggeristä se määrä, kuinka paljon siirrytään taaksepäin
%avg_end=triggeristä se määrä, kuinka paljon siirrytään eteenpäin

%avgs=nx(avg_start+avg_end) matriisi, jossa kanavakohtaiset keskiarvot
    if nargin<5
        corr=0;
    end
    mask=avg_start:avg_end;
    avg_lenght=length(mask);
    chn_length=size(data,1);
    mask=repmat(mask,length(triggers),1);

    trigs=repmat(triggers.',1,size(mask,2));
    mask=int32(trigs)+int32(mask);
    mask=mask(sum(mask<0,2)==0,:);
    mask=mask(sum(mask>length(data),2)==0,:);
    trig_length=size(mask,1);

    avgs=reshape(data(:,mask),[chn_length,trig_length,avg_lenght]);
    %a=squeeze(avgs(76,:,:));
    size(data,1)
    groups=1:size(data,1);
    if corr>0
        corr_mat=zeros(size(data,1),trig_length,trig_length);
        for i=1:size(data,1)
            corr_mat(i,:,:)= corrcoef(squeeze(avgs(i,:,:))');
        end
        mean_corr=squeeze(mean(corr_mat));
        %mean_corr(mean_corr<corr)=0;
        
        Z = linkage(mean_corr,'single','correlation');
        [groups,best_corr]=get_best_group(Z,200);
        
        %dendrogram(Z,0,'colorthreshold',cor)
        %imagesc(mean_corr)
    end
    
    avgs=reshape(mean(avgs,2),[chn_length,avg_lenght]);
    avgs=avgs-repmat(avgs(:,1),1,avg_lenght);
    avgs=avgs-repmat(avgs(:,1),1,avg_lenght);
end

function [groups,best_corr]=get_best_group(z,treshold)
    cur_idx=double(size(z,1))+1;
    map=ownmap(cur_idx);
    for i=1:size(z,1)
        cur_idx=cur_idx+1;
        map(double(cur_idx))=[map(z(i,1)),map(z(i,2))];
        if map.largest_group()>treshold
           break
        end
    end
    groups=map.best_indexes();
    groups=groups{:};
    best_corr=map(z(i,3));
end
