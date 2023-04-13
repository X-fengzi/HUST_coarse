function out = IFFT_cp(data,N_fft,N_cp)
%%
ifft_data = ifft(data); %IFFT变换
%把ifft的末尾N_cp个数补充到最前面
out =[ifft_data(N_fft-N_cp+1:end,:);ifft_data];
end
