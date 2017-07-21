function [ssp_grads,ssp_mags] = ssp(grads,mags,projs,grad_idx,mag_idx)
    projections=ones(7,99);
    for i=1:7
        projs(i).active=1;
    end
%     [U,S,~]=svd(projections(1:5,mag_idx).');
%     U;
%     S = diag(S);
%     nproj=sum(sum(S/S(1)> 1e-2));
%     U=U(:,1:nproj);
%     size(mags)
%     proj=eye(size(mags,1),size(mags,1))-U*U.';
    
%     [U,S,~]=svd(projections(6:end,grad_idx).');
%     nproj=sum(sum(S/S(1)> 1e-2));
%     U=U(:,1:nproj);
%     proj=eye(size(grads,1),size(grads,1))-U*U.';
%     ssp_grads=proj*grads;    
    
    chns=projs(1).data.col_names(mag_idx);
    [proj,~,~]=mne_make_projector(projs(1:5),chns,[]);
    ssp_mags=proj*mags;
    
    chns=projs(1).data.col_names(grad_idx);
    [proj,~,~]=mne_make_projector(projs(6:end),chns,[]);
    ssp_grads=proj*grads;
end

