function [cazac_sequence]=create_cazac(signal_length)
%% 参数说明
% signal_length CAZAC序列的生成长度
% cazac_sequence 生成的CAZAC序列
%%
K=signal_length-1;
n=1:signal_length;
if mod(signal_length,2)==0
    cazac_sequence=exp(1j*2*pi*K/signal_length*(n.*n/2+n));
else
    cazac_sequence=exp(1j*2*pi*K/signal_length*(n.*(n+1)/2+n));
end
cazac_sequence = cazac_sequence';
end