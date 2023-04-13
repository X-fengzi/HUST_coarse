clear
clc
close all
%% 初始化
fs = 10e6;              %基带频率
det_f = 0;
f = 433e6;            %载波频率
SamplesPerFrame = 12e6;
tx = sdrtx('Pluto','CenterFrequency',f+det_f,...
    'BasebandSampleRate',fs,...
    'Gain',0);
rx = sdrrx('Pluto','CenterFrequency',f,...
    'OutputDataType','double',...
    'BasebandSampleRate',fs,...
    'SamplesPerFrame',SamplesPerFrame,...
    'GainSource','Manual',...
    'Gain',40);
sps = 8; 											%采样次数
Rolloff = 0.6; 										%滚降系数
normalize_factor = 0.2; 						%功率因子（手动
%根升余弦滤波器
txFilt = comm.RaisedCosineTransmitFilter(...      	%根升余弦滤波器对象
    'OutputSamplesPerSymbol',sps,...                  	%八倍采样的滤波器
    'RolloffFactor',Rolloff);

rxFilt = comm.RaisedCosineReceiveFilter(...
    'InputSamplesPerSymbol',sps,...
    'DecimationFactor',1,...
    'RolloffFactor',Rolloff);
%% 参数设置

% 控制是否画图，0--不画图；1--画图；程序运行时间较长时，建议置零，或者文件较小时（帧数少）可选择画图
flagdraw = 0; 

N_fft=64;                                           % FFT 长度
N_cp=4;                                            % 循环前缀长度、Cyclic prefix
N_symbo=N_fft+N_cp;                                 % 1个完整OFDM符号长度
N_c=53;                                             % 包含直流载波和空载波的总的子载波数、number of carriers
N_zero = 11;                                         %空载波数量
M=16;                                               %MQAM调制(M=4时，即为QPSK)
k = 1;                                            %电平值
frame_length = 12096;                                %帧长度
syn_length1 = 128;                                   %粗同步码长度
synWord1 = k*create_cazac(syn_length1);               %粗同步码
synWord2 = k*[1;1;1;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;1;1;-1;-1;1;1;-1;1;-1;1]; 
syn_length2 = length(synWord2);                      %精同步码长度
synWord = [synWord1;synWord2];
freWord = create_cazac(16);
freWord = repmat(freWord.',1,10);
waitWord = randi([0,1],1000,1); 							%收发间歇码
NormalizedLoopBandwidth = 0.04;                             %规范化的环路带宽
%数据（QAM调制后）长度
data_QAM_length = ceil(frame_length*2/log2(M)/(N_c-N_zero))*(N_fft+N_cp);
%帧（QAM调制后,即待发送的帧）长度
frame_QAM_length = ceil(frame_length*2/log2(M)/(N_c-N_zero))*(N_fft+N_cp)+length(synWord)+length(waitWord)+length(freWord);

%% OFDM 通信过程
file_name = 'test_10Mb.pdf';
filename_bits = filename_encode(file_name);
bitstream_info = Encoder(file_name);                     %编码生成比特流
bitstream = [bitstream_info,filename_bits];
frames = Frame(bitstream,frame_length);             %将源比特流分帧发送
frame_size = size(frames);
data_Tx = zeros(frame_QAM_length,frame_size(1));
%对每个帧进行信道编码、组OFDM、插入同步码操作
for m = 1:frame_size(1)
    frame = frames(m,:);
    bits_channel = channel_coding(frame);           %卷积编码
    data_QAM = QAM(bits_channel,M);                     %QAM映射
    data_pilot = pilot(data_QAM,N_fft,N_c,N_zero);                 %加入导频，空载波，组成一个OFDM信号
    data_ifft = IFFT_cp(data_pilot,N_fft,N_cp);         %IFFT，添加循环前缀
    data_Tx1 = reshape(data_ifft,[],1);                 %并串转换
    data_Tx2 = [synWord;freWord.';data_Tx1;waitWord];             %插入同步码
    data_Tx(:,m) = data_Tx2;
end
%并串转换，送给Tx循环发送
Tx_all = reshape(data_Tx,[],1);
Tx_length = 25*log2(M)*frame_QAM_length;
if mod(length(Tx_all),Tx_length)~=0
    Tx_tail = Tx_all(1+Tx_length*floor(length(Tx_all)/Tx_length):end);
    Tx_tail_all = [];
    for i = 1:floor(Tx_length/length(Tx_tail))
        Tx_tail_all = [Tx_tail_all;Tx_tail];
    end
    Tx_tail_all = [Tx_tail_all;zeros(Tx_length-floor(Tx_length/length(Tx_tail))*length(Tx_tail),1)];
    Tx_total = [Tx_all(1:floor(length(Tx_all)/Tx_length)*Tx_length);Tx_tail_all];
end
Tx_total = txFilt(Tx_total);

Tx_total = reshape(Tx_total,Tx_length*sps,[]);

Tx_size = size(Tx_total);

if Tx_size(2)>1
    t = 0;
    while(1)
        Tx = Tx_total(:,1+mod(t,Tx_size(2)));
        tx.transmitRepeat(Tx);
        pause(5);
        t = t+1;
    end
else
    Tx = Tx_total;
    tx.transmitRepeat(Tx);
end




