function [out,err,num_frame,sum_frame,len] = de_Frame(data,frame_length)
%%
CRC_code = 'z^16 + z^15 + z^2 + 1';    % CRC��������
crcDet = comm.CRCDetector(CRC_code);                        %CRC-16 ѭ������У����
N = 10;                                                     %��N�����ر�ʾ֡�����
% sum_frame_length = N;                                       %��N������֡������
% num_frame_length = N;                                       %��N�����ر�ʾ֡�����
num_bits_length = ceil(log2(frame_length));                 %�⼸�����ر�ʾһ֡���������ݱ�������
crc_length = 16;

[~, err] = crcDet(data);      %CRC����
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

