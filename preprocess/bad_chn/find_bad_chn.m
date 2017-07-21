function [bads] = find_bad_chn(data,len_beats)
%Valitsee huonot kanavat triggausten perusteella ja sen, kuinka paljon
%qrs triggausten määrä on vaihdellut, sekä magnetometreissä tarkistaa, että
%korrelaatio on tarpeeksi suurta
    max_diff=5;
    mags=1:3:99;
    grads=setdiff(1:99,mags);
    most_common_grads=mode(len_beats(grads));
    most_common_mags=mode(len_beats(mags));
    most_common_ecg=mode(len_beats(107:end));
    
    bads=ones(size(data,1),1);
    bads(grads)=abs(len_beats(grads)-most_common_grads)>max_diff;
    bads(mags)=abs(len_beats(mags)-most_common_mags)>max_diff;
    bads(109:end)=abs(len_beats(109:end)-most_common_ecg)>max_diff;
    mags=data(1:3:99,:);
    r=corrcoef(mags.');
    bads(1:3:99,:)=bads(1:3:99,:)&(mean(r)<0.95).';
end

