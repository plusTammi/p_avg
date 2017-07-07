function [ baseline ] = baseline(data,triggers,baseline_point)
%BASELINE Summary of this function goes here
%   Detailed explanation goes here
    baseline=zeros(size(data));
    xq=1:length(data);
    x=triggers+baseline_point;
    x(x<1)=1;
    y=data(:,x);
    size(x)
    size(y)
    size(xq)
    for i=1:size(data,1)
        temp=spline(double(x),double(y(i,:)),xq);
        baseline(i,:)=spline(double(x),double(y(i,:)),xq);
    end
    plot(data(1,:)-baseline(1,:))
end

