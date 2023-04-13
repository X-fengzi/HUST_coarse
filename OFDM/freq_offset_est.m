function [out,freq_off_set]=freq_offset_est(rx_data,fs) 
%%
% rx_data��
% fs:������
off_set=30;      % �� ����������������
len=128;         % % ֡ͬ�� CAZAC�� ������ ����Ϊ128��
                 % ���߿�����Ϊ�� ���ݲ������� Ncp?
D=16;            % ��Ϊ���� Ƶƫ���Ƶ� CAZAC�� ������ ����Ϊ16
% B = 20e6;
%% L&R�㷨
tempindex1 = off_set+1:off_set+len-D;
tempindex2 = off_set+D+1:off_set+len;
x_corr=rx_data(tempindex1).*conj(rx_data(tempindex2));

x_n2 = sum(sum(x_corr));
freq_off_set = -angle(x_n2)./(2*pi*16)*fs;    %
% ���Ƶƫֵ�󣬽���Ƶ�ʲ���
n=(0:length(rx_data)-1).';
out=rx_data.*exp(-1i*2*pi*freq_off_set/fs.*n);
end