function out = IFFT_cp(data,N_fft,N_cp)
%%
ifft_data = ifft(data); %IFFT�任
%��ifft��ĩβN_cp�������䵽��ǰ��
out =[ifft_data(N_fft-N_cp+1:end,:);ifft_data];
end
