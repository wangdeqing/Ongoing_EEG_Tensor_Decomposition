%%% This code was written by Dr. Vinoo Alluri and Prof. Petri Toiviainen in 2012
%%% Using this code, please cite
%%%
%%% Alluri V, Toiviainen P, Jaaskelainen IP, Glerean E, Sams M,Brattico E
%%% Large-scale brain networks emerge from dynamic processing of musical timbre, key and rhythm.
%%% Neuroimage (2012) 59:3677-3689
%%%
function [p05, p01, p001]=f_p_threshold_oneDim(T,Feature_scores)
%%% T contains the temporal courses of brain data
%%% Feature_scores contains the temporal courses of musical features
%%% each column is one temporal course in T and Feature_scores
sizeT = size(T);
no_of_tcs=sizeT(2);%%%
no_of_loops=100000;
for feat_no=1:size(Feature_scores,2)
    fprintf('Feature Number: %d\n',feat_no);
    feature=Feature_scores(:,feat_no);
    index=1;
    corr_values=zeros(no_of_loops,1);  
    for in_loop=1:no_of_loops       
%         fprintf('Loop number: %d\n',in_loop);
        comp_no=randperm(no_of_tcs);        
        comp_time_Series=T(:,comp_no(1));        
        % % %         shift_value=floor(length(feature)*rand(1));
        % % %
        % % %         flip_shift_feature = circshift(flipud(feature),shift_value);
        flip_shift_feature = real(ifft(abs(fft(feature)).*exp(1i*angle(fft(rand(size(feature)))))));
        [r] = corr(comp_time_Series,flip_shift_feature);
        corr_values(index)=r;
        index=index+1;
    end
    corr_results(feat_no).r=corr_values;
    clear corr_values
end
for n=1:size(Feature_scores,2)
    k=corr_results(n).r;
    s=sort(k);
    p001(n)=max(abs(s(.001*no_of_loops/2)),abs(s(end-((.001*no_of_loops/2)+1))));
    p01(n)=max(abs(s(.01*no_of_loops/2)),abs(s(end-((.01*no_of_loops/2)+1))));
    p05(n)=max(abs(s(.05*no_of_loops/2)),abs(s(end-((.05*no_of_loops/2)+1))));
end

