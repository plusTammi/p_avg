function [ baseline ]  = baseline_lsqspline(data,triggers,borders)
    x=1:size(data,2);
    knots=sort(horzcat(triggers+borders(1),triggers+borders(end)));
    
    weight=borders(1):borders(end);
    weight=repmat(weight,length(triggers),1);
    weight=weight+repmat(triggers,length(weight),1)';
    weight=sort(reshape(weight,1,[]));
    weight=weight(weight>0);
    weight=weight(weight<length(x));
    
    w=ones(length(x),1);
    w(weight)=0;
    x(w==1);
    sp=spap2(knots,3,x,data,w);
    baseline=fnval(sp,x);
end

