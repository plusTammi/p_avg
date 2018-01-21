function [ p_trigs ] = p_trig(data,qrs_trigs, borders)
%p triggaus, keskeneräinen
    mask=borders(1)-50:borders(3)-25;
    mask_lenght=length(mask);

    mask=repmat(mask,length(qrs_trigs),1);
    trigs=repmat(qrs_trigs.',1,size(mask,2));
    mask=int32(trigs)+int32(mask);
    mask=mask(sum(mask<0,2)==0,:);

    mask=mask(sum(mask>length(data(4,:)),2)==0,:);
    trig_length=size(mask,1);
    p_trigs=zeros(2,size(qrs_trigs,2));
    %p_trigs=zeros(1,size(qrs_trigs,2));
    for chn=1:size(data,1)
        
        avgs=reshape(data(chn,mask),[trig_length,mask_lenght]);
        template=mean(avgs);
        template=template-template(1);

        for i=1:size(avgs,1)
            [r,lag]=xcov(template,avgs(i,:),60,'coeff');
            [~,ind]=max(r);
            if max(r)>p_trigs(2,i)
                p_trigs(1,i)=lag(ind);%;finddelay(template,avgs(i,:),50);
                p_trigs(2,i)=max(r);
            end
        end
    end
    p_trigs=p_trigs(1,:);
end

