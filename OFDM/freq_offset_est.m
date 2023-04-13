function [out,freq_off_set]=freq_offset_est(rx_data,fs) 
%%
% rx_data：
% fs:采样率
off_set=30;      % ？ ？？？？？？？？
len=128;         % % 帧同步 CAZAC码 长序列 长度为128？
                 % 或者可以认为是 数据采样点数 Ncp?
D=16;            % 因为生成 频偏估计的 CAZAC码 短序列 长度为16
% B = 20e6;
%% L&R算法
tempindex1 = off_set+1:off_set+len-D;
tempindex2 = off_set+D+1:off_set+len;
x_corr=rx_data(tempindex1).*conj(rx_data(tempindex2));

x_n2 = sum(sum(x_corr));
freq_off_set = -angle(x_n2)./(2*pi*16)*fs;    %
% 算出频偏值后，进行频率补偿
n=(0:length(rx_data)-1).';
out=rx_data.*exp(-1i*2*pi*freq_off_set/fs.*n);
end