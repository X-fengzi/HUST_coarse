function [cazac_sequence]=create_cazac(signal_length)
%% ����˵��
% signal_length CAZAC���е����ɳ���
% cazac_sequence ���ɵ�CAZAC����
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