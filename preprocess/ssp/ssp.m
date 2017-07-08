function [ssp_grads,ssp_mags] = ssp(grads,mags,projs,grad_idx,mag_idx)
%Nopeasti kyhätty versio, pitää tarkistaa
    projections=ones(7,99);
    for i=1:7
        projections(i,:)=projs(i).data.data;
    end
    [U,S,~]=svd(projections(1:5,mag_idx).');
    nproj=sum(sum(S/S(1)> 1e-2));
    U=U(:,1:nproj);
    proj=eye(size(mags,1),size(mags,1))-U*U.';
    ssp_mags=proj*mags;
    
    [U,S,~]=svd(projections(6:end,grad_idx).');
    nproj=sum(sum(S/S(1)> 1e-2));
    U=U(:,1:nproj);
    proj=eye(size(grads,1),size(grads,1))-U*U.';
    ssp_grads=proj*grads;    
end

