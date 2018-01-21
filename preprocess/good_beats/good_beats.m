function [ good_beats,best_corr ] = good_beats( data,triggers,avg_start,avg_end,treshold)
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

    corr_mat=zeros(size(data,1),trig_length,trig_length);
    for i=1:size(data,1)
        corr_mat(i,:,:)= corrcoef(squeeze(avgs(i,:,:))');
        %fprintf('%d,%d\n',i,mean(mean(corr_mat(i,:,:))))
    end
    
    mean_corr=squeeze(max(corr_mat));

    %imagesc(mean_corr)
    mean_corr=squareform(mean_corr-eye(size(mean_corr)));

    %mean_corr(mean_corr<corr)=0;
    Z = linkage(1-mean_corr,'average');
    [groups,best_corr]=get_best_group(Z,treshold);
    groups=cluster(Z,'cutoff',1-treshold,'criterion','distance');
    [a,b]=hist(groups,unique(groups));
    [~,idx]=max(a);

    %dendrogram(Z,0,'colorthreshold',1-treshold)
    %inconsistent(Z)
    %imagesc(mean_corr)
    good_beats=groups;

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
