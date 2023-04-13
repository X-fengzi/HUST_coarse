clear
clc
close all
%% 初始化
fs = 10e6;              %基带频率
det_f = 0;
f = 4.33e+08;            %载波频率
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
k = 1;                                             %电平值
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

%% 发送端
file_name = 'test_1Mb.txt';
filename_bits = filename_encode(file_name);
bitstream_info = Encoder(file_name);                     %编码生成比特流
bitstream = [bitstream_info,filename_bits];
frames = Frame(bitstream,frame_length);             %将源比特流分帧发送
frame_size = size(frames);
data_Tx = zeros(frame_QAM_length,frame_size(1));
% 对每个帧进行信道编码、组OFDM、插入同步码操作
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
% 并串转换，送给Tx循环发送
Tx_all = reshape(data_Tx,[],1);
number = 25*log2(M);
Tx_length = number*frame_QAM_length;
if mod(length(Tx_all),Tx_length)~=0
    Tx_tail = Tx_all(1+Tx_length*floor(length(Tx_all)/Tx_length):end);
    Tx_tail_all = [];
    for i = 1:floor(Tx_length/length(Tx_tail))
        Tx_tail_all = [Tx_tail_all;Tx_tail];
    end
    Tx_tail_all = [Tx_tail_all;zeros(Tx_length-floor(Tx_length/length(Tx_tail))*length(Tx_tail),1)];
    Tx_total = [Tx_all(1:floor(length(Tx_all)/Tx_length)*Tx_length);Tx_tail_all];
else
    Tx_total = Tx_all;
end

Tx_total = txFilt(Tx_total);
Tx_total = reshape(Tx_total,Tx_length*sps,[]);
Tx_size = size(Tx_total);
%% 接收端
over=1;                         %标志是否接收到除尾帧外的所有帧
tag = 0;                        %标志是否接收到第一个正确的帧
t = 0;                          %标志发送了多少轮(实际发送轮数为t+1)
%%循环接收，直至正确接收到所有帧
while(over)
    Tx = Tx_total(:,1+mod(t,Tx_size(2)));
    tx.transmitRepeat(Tx);
    for i=1:4
        [Rx,datavalid,overflow] = rx();
    end
    % release(tx); 									  	%释放Pluto
    data_Rx1 = rxFilt(Rx);
    %时间同步
    symsync = comm.SymbolSynchronizer(...             	%这里的参数都可以调节
        'TimingErrorDetector','Gardner (non-data-aided)',...
        'NormalizedLoopBandwidth',NormalizedLoopBandwidth,...
        'DampingFactor',2,...
        'SamplesPerSymbol',sps);
    data_Rx2 = step(symsync,data_Rx1);
    % 用matlab自带函数计算频偏
    freqComp = comm.CoarseFrequencyCompensator(...
        'Modulation','QAM', ...
        'SampleRate',fs, ...
        'FrequencyResolution',1);
    [data_Rx3,estFreqOffset1] = freqComp(data_Rx2);
    %%
    % 码元同步
    syn_data1 = synWord1(end:-1:1);
    syn_data2 = synWord2(end:-1:1);
    data_conv1 = conv(syn_data1,data_Rx3);

    % 粗同步
    loc1 = find(abs(data_conv1)>0.7*max(abs(data_conv1)));
    if length(loc1)<1
        continue;
    else
        loc = loc1(1);
        % 两个粗同步的位置需要大于一个帧长
        for j = 1:length(loc1)-1
            if loc1(j+1)-loc(end)<frame_QAM_length
                continue;
            else
                loc = [loc,loc1(j+1)];
            end
        end
    end
    if flagdraw == 1 % 是否需要画图
        % 粗同步图像 时间序列
        figure(1)
        plot(abs(data_conv1))
        xlabel("时间序列")
        ylabel("相关度")
        title("相关性分析（粗同步）图像")
    end
    %% 根据粗同步取出帧
    for i = 1:length(loc)-1
        if loc(i)-length(syn_data1)<=0            % 避免残缺的帧
            continue
        else
            data_Rx4 = data_Rx3(loc(i)-length(syn_data1):loc(i+1)-length(syn_data1));
        end
        % 精同步，找到数据的精确位置
        data_conv2 = conv(syn_data2,data_Rx4);
        [data_conv_max , data_conv_max_addr] = max(abs(data_conv2)); % 卷积最大值
        data_addr = data_conv_max_addr(1) - length(syn_data2); % 同步字段的起始位置
        
        % 取出一帧的数据
        if data_conv_max_addr+data_QAM_length+length(freWord)>length(data_Rx4) %避免残缺的帧
            continue
        else
            % data_Rx = 1/e_phase*data_Rx4(data_conv_max_addr+1:data_conv_max_addr+data_QAM_length);   % 截取数据部分
            data_Rx =data_Rx4(data_conv_max_addr+1:data_conv_max_addr+data_QAM_length+length(freWord));
        end
        [data_Rx,estFreqOffset2]=freq_offset_est(data_Rx, fs);%信号进行频偏估计
        data_Rx = data_Rx(161:end);
        % 功率归一化，利用所有有用信号的绝对值均值
        data_Rx =  normalize_factor*data_Rx./sqrt(mean(abs(data_Rx).^2));
        data_Rx = reshape(data_Rx,N_symbo,[]);                                          %串并转换
        data_fft = FFT_cp(data_Rx,N_cp);                                          %FFT，去除循环前缀
        data_equalization = equalization(data_fft,N_fft,N_c,N_zero);                  %信道均衡

        data_deQAM = de_QAM(data_equalization,M);                                        %QAM逆映射
        data_deChannel = channel_decoding(data_deQAM);                                  %信道译码    
        % 解帧，返回帧序号和帧总数及数据信息,若帧校验出错，则返回的帧序号和帧总数均为0
        [frame,err,num_frame,sum_frame,len] = de_Frame(data_deChannel,frame_length);
        frame_len = length(frame);
        
        if flagdraw == 1
            % 精同步图像 时间序列
            figure(2)
            plot(abs(data_conv2))
            xlabel("时间序列")
            ylabel("相关度")
            title("相关性分析（精同步）图像")
            % 均衡前图像
            scatterplot(reshape(data_fft,[],1))
            title("均衡前")
            % 均衡后图像
            scatterplot(data_equalization)
            title("均衡后")
        end
        %% 打印接收情况
        if err ~=0 || sum_frame==0                              % 帧校验出错，丢弃帧
            fprintf("数据帧解调出错!\n")
            continue;
        elseif num_frame<=sum_frame && tag ==0                   % 判断是否为收到的第一个帧
            frame_receive = zeros(sum_frame,frame_len);   %%
            frame_over=zeros(1,sum_frame);
            tag = 1;
            frame_receive(num_frame,:) = frame;
            frame_over(num_frame) = 1;
            if num_frame==sum_frame
                tail_len = len;
            end
            fprintf("接收到第%d帧，已接收到%d帧,总共需要接收%d帧\n",num_frame,sum(frame_over,2),sum_frame)
        elseif num_frame<=sum_frame && tag ==1 && frame_over(num_frame) == 0
            frame_receive(num_frame,:) = frame;
            frame_over(num_frame) = 1;
            fprintf("接收到第%d帧，已接收到%d帧,总共需要接收%d帧\n",num_frame,sum(frame_over,2),sum_frame)
            if num_frame==sum_frame
                tail_len = len;
            end
        end
        if sum(frame_over,2)==sum_frame
            fprintf('成功接收完所有数据帧\n')
            over=0;
            break;
        end
    end
    if tag==0                                 %若接收不到正确的帧则会打印提示信息
        fprintf('初始化接收失败')
    elseif sum(frame_over,2)<sum_frame           
        fprintf('成功接收%d帧数据,还有%d个帧需要接收\n',sum(frame_over,2),sum_frame-sum(frame_over,2))
    end
 t = t+1;
end
%% 信宿解码
bits_receive_pre = reshape(frame_receive(1:end-1,:),1,[]);
bits_receive = [bits_receive_pre,frame_receive(end,1:tail_len)]; % 补上尾帧
[bits_info,filename_R] = filename_decode(bits_receive);
filename_R = strcat('R_',filename_R);
Decoder(bits_info,filename_R); % 
%% 打印准确率
accuracy_percentage = length(find(bits_info==bitstream_info))/length(bitstream_info)*100;
disp(['准确率为：' num2str(accuracy_percentage) '%'])