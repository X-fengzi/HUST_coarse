function out = channel_coding(bitstream)
%% Turbo����
%bits_in:����ı������
%codewordLen:���������ı��س��ȣ�������������Ա���Ч�ʣ�

codewordLen = 2*length(bitstream);
cbs=lteCodeBlockSegment(bitstream);
te=lteTurboEncode(cbs);
rmt=lteRateMatchTurbo(te,codewordLen,0).';
out=double(rmt);      %��������
end
