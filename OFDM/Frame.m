function out = Frame(bitstream,frame_length)
% frame_length = 12096;
% bitstream = randi([0,1],1,1000);
%% 帧的信息比特
CRC_code = 'z^16 + z^15 + z^2 + 1';    % CRC生成序列
crcGen = comm.CRCGenerator('Polynomial',CRC_code);   %CRC-16 循环冗余校验码
N = 10;                                                     %用N个比特表示帧的序号
sum_frame_length = N;                                       %这N个比特帧的总数
num_frame_length = N;                                       %这N个比特表示帧的序号
num_bits_length = ceil(log2(frame_length));                 %这几个比特表示一帧包含的数据比特数量
crc_length = 16;
%% 组帧

data_length = frame_length-sum_frame_length-num_frame_length-num_bits_length-crc_length;
if length(bitstream)>data_length
if mod(length(bitstream),data_length) ~=0                   %尾帧补零
    bitstream_tail = bitstream(end-mod(length(bitstream),data_length)+1:end);
    bitstream = bitstream(1:length(bitstream)-mod(length(bitstream),data_length)); 
    bitstream = reshape(bitstream,[],data_length);%除去尾帧的其它帧(交织，避免发送数据连续出现过多1)
%     bitstream = reshape(bitstream,data_length,[]);
%     bitstream = bitstream';
     
    size_data = size(bitstream);
    frame_size = [size_data(1)+1,frame_length];    
    frames = zeros(frame_size);  %预设整个帧
    
    for i = 1:size_data(1)
        data = bitstream(i,:);
        pre_num_frame = de2bi(i,N);                             %帧的序号编码
        pre_sum_frame = de2bi(frame_size(1),N);                 %帧的总数编码
        pre_num_bits = de2bi(size_data(2),num_bits_length);     %帧的数据长度编码
        frame = [pre_num_frame pre_sum_frame pre_num_bits data];%帧拼接
        
        frame =frame';
        frame = crcGen(frame);
        frame = frame';
        
        frames(i,:) = frame;            %填充帧
    end
    %加入尾帧
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
%以下代码逻辑均与上述填充帧逻辑相似
else
%     bitstream = reshape(bitstream,data_length,[]);
%     bitstream = bitstream';
    bitstream = reshape(bitstream,[],data_length);%除去尾帧的其它帧
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