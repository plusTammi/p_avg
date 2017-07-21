function [ baseline ] = baseline_spline(data,triggers,baseline_point)
%Canalyse tyyppinen baselinekorjaus
%Palauttaa baselinen, jonka voi poistaa datasta
    baseline=zeros(size(data));
    xq=1:length(data);
    x=triggers+baseline_point;
    x(x<1)=1;
    y=data(:,x);
    for i=1:size(data,1)
        temp=spline(double(x),double(y(i,:)),xq);
        baseline(i,:)=spline(double(x),double(y(i,:)),xq);
    end
end

