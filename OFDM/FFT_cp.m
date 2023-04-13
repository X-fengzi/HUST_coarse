function out = FFT_cp(data,N_cp)
%%
data=data(N_cp+1:end,:);     %去除循环前缀
out=fft(data);               %FFT变换
end