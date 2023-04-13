function out = channel_coding(bitstream)
%% Turbo编码
%bits_in:输入的编码比特
%codewordLen:编码后输出的比特长度（输入比特数除以编码效率）

codewordLen = 2*length(bitstream);
cbs=lteCodeBlockSegment(bitstream);
te=lteTurboEncode(cbs);
rmt=lteRateMatchTurbo(te,codewordLen,0).';
out=double(rmt);      %编码后比特
end
