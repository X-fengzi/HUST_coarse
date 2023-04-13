function [out,err,num_frame,sum_frame,len] = de_Frame(data,frame_length)
%%
CRC_code = 'z^16 + z^15 + z^2 + 1';    % CRC生成序列
crcDet = comm.CRCDetector(CRC_code);                        %CRC-16 循环冗余校验码
N = 10;                                                     %用N个比特表示帧的序号
% sum_frame_length = N;                                       %这N个比特帧的总数
% num_frame_length = N;                                       %这N个比特表示帧的序号
num_bits_length = ceil(log2(frame_length));                 %这几个比特表示一帧包含的数据比特数量
crc_length = 16;

[~, err] = crcDet(data);      %CRC解检测
if err~=0
    out=0;
    num_frame=0;
    sum_frame=0;
    len=0;
else
    data = data';
    num_frame = bi2de(data(1:N));
    sum_frame = bi2de(data(N+1:2*N));
    len = bi2de(data(2*N+1:2*N+num_bits_length));
    out = data(2*N+num_bits_length+1:end-crc_length);
end
end

