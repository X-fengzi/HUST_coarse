function out = FFT_cp(data,N_cp)
%%
data=data(N_cp+1:end,:);     %ȥ��ѭ��ǰ׺
out=fft(data);               %FFT�任
end