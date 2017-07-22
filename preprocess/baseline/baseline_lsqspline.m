function [ baseline ]  = baseline_lsqspline(data,triggers,borders)
    x=1:size(data,2);
    borders(1)
    borders(end)
    knots=sort(horzcat(triggers+borders(1)-100,triggers+(borders(2)+borders(3))/2,triggers+borders(end)+100));
    
    weight=horzcat(borders(1):(borders(2)+10),(borders(3)-10):borders(end));
    weight=repmat(weight,length(triggers),1);
    weight=weight+repmat(triggers,length(weight),1)';
    weight=sort(reshape(weight,1,[]));
    weight=weight(weight>0);
    weight=weight(weight<length(x));
    
    w=ones(length(x),1);
    w(weight)=0;
    sp=spap2(knots,3,x,data,w);
    baseline=fnval(sp,x);
end

