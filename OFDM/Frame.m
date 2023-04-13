function out = Frame(bitstream,frame_length)
% frame_length = 12096;
% bitstream = randi([0,1],1,1000);
%% ֡����Ϣ����
CRC_code = 'z^16 + z^15 + z^2 + 1';    % CRC��������
crcGen = comm.CRCGenerator('Polynomial',CRC_code);   %CRC-16 ѭ������У����
N = 10;                                                     %��N�����ر�ʾ֡�����
sum_frame_length = N;                                       %��N������֡������
num_frame_length = N;                                       %��N�����ر�ʾ֡�����
num_bits_length = ceil(log2(frame_length));                 %�⼸�����ر�ʾһ֡���������ݱ�������
crc_length = 16;
%% ��֡

data_length = frame_length-sum_frame_length-num_frame_length-num_bits_length-crc_length;
if length(bitstream)>data_length
if mod(length(bitstream),data_length) ~=0                   %β֡����
    bitstream_tail = bitstream(end-mod(length(bitstream),data_length)+1:end);
    bitstream = bitstream(1:length(bitstream)-mod(length(bitstream),data_length)); 
    bitstream = reshape(bitstream,[],data_length);%��ȥβ֡������֡(��֯�����ⷢ�������������ֹ���1)
%     bitstream = reshape(bitstream,data_length,[]);
%     bitstream = bitstream';
     
    size_data = size(bitstream);
    frame_size = [size_data(1)+1,frame_length];    
    frames = zeros(frame_size);  %Ԥ������֡
    
    for i = 1:size_data(1)
        data = bitstream(i,:);
        pre_num_frame = de2bi(i,N);                             %֡����ű���
        pre_sum_frame = de2bi(frame_size(1),N);                 %֡����������
        pre_num_bits = de2bi(size_data(2),num_bits_length);     %֡�����ݳ��ȱ���
        frame = [pre_num_frame pre_sum_frame pre_num_bits data];%֡ƴ��
        
        frame =frame';
        frame = crcGen(frame);
        frame = frame';
        
        frames(i,:) = frame;            %���֡
    end
    %����β֡
    pre_num_frame = de2bi(frame_size(1),N);
    pre_sum_frame = de2bi(frame_size(1),N);
    pre_num_bits = de2bi(length(bitstream_tail),num_bits_length);
    frame_tail = [pre_num_frame pre_sum_frame pre_num_bits bitstream_tail];
    
    supple_bits = randi([0,1],1,data_length-length(bitstream_tail));
    frame_tail = [frame_tail supple_bits];
    
    frame_tail =frame_tail';
    frame_tail = crcGen(frame_tail);
    frame_tail = frame_tail';
    
    frames(end,1:length(frame_tail)) = frame_tail;
%���´����߼������������֡�߼�����
else
%     bitstream = reshape(bitstream,data_length,[]);
%     bitstream = bitstream';
    bitstream = reshape(bitstream,[],data_length);%��ȥβ֡������֡
    size_data = size(bitstream);
    frame_size = [size_data(1),frame_length];
    frames = zeros(frame_size);
    
    for i = 1:frame_size(1)
        data = bitstream(i,:);
        pre_num_frame = de2bi(i,N);
        pre_sum_frame = de2bi(frame_size(1),N);
        pre_num_bits = de2bi(size_data(2),num_bits_length);
        frame = [pre_num_frame pre_sum_frame pre_num_bits data];
        
        frame = frame';
        frame = crcGen(frame);
        frame = frame';
        
        frames(i,:) = frame;
    end
    
end
else
    frames = zeros(1,frame_length);
    frame_size = size(frames);
    pre_num_frame = de2bi(frame_size(1),N);
    pre_sum_frame = de2bi(frame_size(1),N);
    pre_num_bits = de2bi(length(bitstream),num_bits_length);
    frame = [pre_num_frame pre_sum_frame pre_num_bits bitstream];
    
    supple_bits = randi([0,1],1,data_length-length(bitstream));
    frame = [frame supple_bits];
    
    frame = frame';
    frame = crcGen(frame);
    frame = frame';
    
    frames(1,1:length(frame)) = frame;    
end
out = frames;
end