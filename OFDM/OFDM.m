clear
clc
close all
%% ��ʼ��
fs = 10e6;              %����Ƶ��
det_f = 0;
f = 4.33e+08;            %�ز�Ƶ��
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
sps = 8; 											%��������
Rolloff = 0.6; 										%����ϵ��
normalize_factor = 0.2; 						%�������ӣ��ֶ�
%���������˲���
txFilt = comm.RaisedCosineTransmitFilter(...      	%���������˲�������
    'OutputSamplesPerSymbol',sps,...                  	%�˱��������˲���
    'RolloffFactor',Rolloff);

rxFilt = comm.RaisedCosineReceiveFilter(...
    'InputSamplesPerSymbol',sps,...
    'DecimationFactor',1,...
    'RolloffFactor',Rolloff);
%% ��������

% �����Ƿ�ͼ��0--����ͼ��1--��ͼ����������ʱ��ϳ�ʱ���������㣬�����ļ���Сʱ��֡���٣���ѡ��ͼ
flagdraw = 0; 

N_fft=64;                                           % FFT ����
N_cp=4;                                            % ѭ��ǰ׺���ȡ�Cyclic prefix
N_symbo=N_fft+N_cp;                                 % 1������OFDM���ų���
N_c=53;                                             % ����ֱ���ز��Ϳ��ز����ܵ����ز�����number of carriers
N_zero = 11;                                         %���ز�����
M=16;                                               %MQAM����(M=4ʱ����ΪQPSK)
k = 1;                                             %��ƽֵ
frame_length = 12096;                                %֡����
syn_length1 = 128;                                   %��ͬ���볤��
synWord1 = k*create_cazac(syn_length1);               %��ͬ����
synWord2 = k*[1;1;1;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;1;1;-1;-1;1;1;-1;1;-1;1;1;1;1;1;1;-1;-1;1;1;-1;1;-1;1]; 
syn_length2 = length(synWord2);                      %��ͬ���볤��
synWord = [synWord1;synWord2];
freWord = create_cazac(16);
freWord = repmat(freWord.',1,10);
waitWord = randi([0,1],1000,1); 							%�շ���Ъ��
NormalizedLoopBandwidth = 0.04;                             %�淶���Ļ�·����
%���ݣ�QAM���ƺ󣩳���
data_QAM_length = ceil(frame_length*2/log2(M)/(N_c-N_zero))*(N_fft+N_cp);
%֡��QAM���ƺ�,�������͵�֡������
frame_QAM_length = ceil(frame_length*2/log2(M)/(N_c-N_zero))*(N_fft+N_cp)+length(synWord)+length(waitWord)+length(freWord);

%% ���Ͷ�
file_name = 'test_1Mb.txt';
filename_bits = filename_encode(file_name);
bitstream_info = Encoder(file_name);                     %�������ɱ�����
bitstream = [bitstream_info,filename_bits];
frames = Frame(bitstream,frame_length);             %��Դ��������֡����
frame_size = size(frames);
data_Tx = zeros(frame_QAM_length,frame_size(1));
% ��ÿ��֡�����ŵ����롢��OFDM������ͬ�������
for m = 1:frame_size(1)
    frame = frames(m,:);
    bits_channel = channel_coding(frame);           %�������
    data_QAM = QAM(bits_channel,M);                     %QAMӳ��
    data_pilot = pilot(data_QAM,N_fft,N_c,N_zero);                 %���뵼Ƶ�����ز������һ��OFDM�ź�
    data_ifft = IFFT_cp(data_pilot,N_fft,N_cp);         %IFFT�����ѭ��ǰ׺
    data_Tx1 = reshape(data_ifft,[],1);                 %����ת��
    data_Tx2 = [synWord;freWord.';data_Tx1;waitWord];             %����ͬ����
    data_Tx(:,m) = data_Tx2;
end
% ����ת�����͸�Txѭ������
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
%% ���ն�
over=1;                         %��־�Ƿ���յ���β֡�������֡
tag = 0;                        %��־�Ƿ���յ���һ����ȷ��֡
t = 0;                          %��־�����˶�����(ʵ�ʷ�������Ϊt+1)
%%ѭ�����գ�ֱ����ȷ���յ�����֡
while(over)
    Tx = Tx_total(:,1+mod(t,Tx_size(2)));
    tx.transmitRepeat(Tx);
    for i=1:4
        [Rx,datavalid,overflow] = rx();
    end
    % release(tx); 									  	%�ͷ�Pluto
    data_Rx1 = rxFilt(Rx);
    %ʱ��ͬ��
    symsync = comm.SymbolSynchronizer(...             	%����Ĳ��������Ե���
        'TimingErrorDetector','Gardner (non-data-aided)',...
        'NormalizedLoopBandwidth',NormalizedLoopBandwidth,...
        'DampingFactor',2,...
        'SamplesPerSymbol',sps);
    data_Rx2 = step(symsync,data_Rx1);
    % ��matlab�Դ���������Ƶƫ
    freqComp = comm.CoarseFrequencyCompensator(...
        'Modulation','QAM', ...
        'SampleRate',fs, ...
        'FrequencyResolution',1);
    [data_Rx3,estFreqOffset1] = freqComp(data_Rx2);
    %%
    % ��Ԫͬ��
    syn_data1 = synWord1(end:-1:1);
    syn_data2 = synWord2(end:-1:1);
    data_conv1 = conv(syn_data1,data_Rx3);

    % ��ͬ��
    loc1 = find(abs(data_conv1)>0.7*max(abs(data_conv1)));
    if length(loc1)<1
        continue;
    else
        loc = loc1(1);
        % ������ͬ����λ����Ҫ����һ��֡��
        for j = 1:length(loc1)-1
            if loc1(j+1)-loc(end)<frame_QAM_length
                continue;
            else
                loc = [loc,loc1(j+1)];
            end
        end
    end
    if flagdraw == 1 % �Ƿ���Ҫ��ͼ
        % ��ͬ��ͼ�� ʱ������
        figure(1)
        plot(abs(data_conv1))
        xlabel("ʱ������")
        ylabel("��ض�")
        title("����Է�������ͬ����ͼ��")
    end
    %% ���ݴ�ͬ��ȡ��֡
    for i = 1:length(loc)-1
        if loc(i)-length(syn_data1)<=0            % �����ȱ��֡
            continue
        else
            data_Rx4 = data_Rx3(loc(i)-length(syn_data1):loc(i+1)-length(syn_data1));
        end
        % ��ͬ�����ҵ����ݵľ�ȷλ��
        data_conv2 = conv(syn_data2,data_Rx4);
        [data_conv_max , data_conv_max_addr] = max(abs(data_conv2)); % ������ֵ
        data_addr = data_conv_max_addr(1) - length(syn_data2); % ͬ���ֶε���ʼλ��
        
        % ȡ��һ֡������
        if data_conv_max_addr+data_QAM_length+length(freWord)>length(data_Rx4) %�����ȱ��֡
            continue
        else
            % data_Rx = 1/e_phase*data_Rx4(data_conv_max_addr+1:data_conv_max_addr+data_QAM_length);   % ��ȡ���ݲ���
            data_Rx =data_Rx4(data_conv_max_addr+1:data_conv_max_addr+data_QAM_length+length(freWord));
        end
        [data_Rx,estFreqOffset2]=freq_offset_est(data_Rx, fs);%�źŽ���Ƶƫ����
        data_Rx = data_Rx(161:end);
        % ���ʹ�һ�����������������źŵľ���ֵ��ֵ
        data_Rx =  normalize_factor*data_Rx./sqrt(mean(abs(data_Rx).^2));
        data_Rx = reshape(data_Rx,N_symbo,[]);                                          %����ת��
        data_fft = FFT_cp(data_Rx,N_cp);                                          %FFT��ȥ��ѭ��ǰ׺
        data_equalization = equalization(data_fft,N_fft,N_c,N_zero);                  %�ŵ�����

        data_deQAM = de_QAM(data_equalization,M);                                        %QAM��ӳ��
        data_deChannel = channel_decoding(data_deQAM);                                  %�ŵ�����    
        % ��֡������֡��ź�֡������������Ϣ,��֡У������򷵻ص�֡��ź�֡������Ϊ0
        [frame,err,num_frame,sum_frame,len] = de_Frame(data_deChannel,frame_length);
        frame_len = length(frame);
        
        if flagdraw == 1
            % ��ͬ��ͼ�� ʱ������
            figure(2)
            plot(abs(data_conv2))
            xlabel("ʱ������")
            ylabel("��ض�")
            title("����Է�������ͬ����ͼ��")
            % ����ǰͼ��
            scatterplot(reshape(data_fft,[],1))
            title("����ǰ")
            % �����ͼ��
            scatterplot(data_equalization)
            title("�����")
        end
        %% ��ӡ�������
        if err ~=0 || sum_frame==0                              % ֡У���������֡
            fprintf("����֡�������!\n")
            continue;
        elseif num_frame<=sum_frame && tag ==0                   % �ж��Ƿ�Ϊ�յ��ĵ�һ��֡
            frame_receive = zeros(sum_frame,frame_len);   %%
            frame_over=zeros(1,sum_frame);
            tag = 1;
            frame_receive(num_frame,:) = frame;
            frame_over(num_frame) = 1;
            if num_frame==sum_frame
                tail_len = len;
            end
            fprintf("���յ���%d֡���ѽ��յ�%d֡,�ܹ���Ҫ����%d֡\n",num_frame,sum(frame_over,2),sum_frame)
        elseif num_frame<=sum_frame && tag ==1 && frame_over(num_frame) == 0
            frame_receive(num_frame,:) = frame;
            frame_over(num_frame) = 1;
            fprintf("���յ���%d֡���ѽ��յ�%d֡,�ܹ���Ҫ����%d֡\n",num_frame,sum(frame_over,2),sum_frame)
            if num_frame==sum_frame
                tail_len = len;
            end
        end
        if sum(frame_over,2)==sum_frame
            fprintf('�ɹ���������������֡\n')
            over=0;
            break;
        end
    end
    if tag==0                                 %�����ղ�����ȷ��֡����ӡ��ʾ��Ϣ
        fprintf('��ʼ������ʧ��')
    elseif sum(frame_over,2)<sum_frame           
        fprintf('�ɹ�����%d֡����,����%d��֡��Ҫ����\n',sum(frame_over,2),sum_frame-sum(frame_over,2))
    end
 t = t+1;
end
%% ���޽���
bits_receive_pre = reshape(frame_receive(1:end-1,:),1,[]);
bits_receive = [bits_receive_pre,frame_receive(end,1:tail_len)]; % ����β֡
[bits_info,filename_R] = filename_decode(bits_receive);
filename_R = strcat('R_',filename_R);
Decoder(bits_info,filename_R); % 
%% ��ӡ׼ȷ��
accuracy_percentage = length(find(bits_info==bitstream_info))/length(bitstream_info)*100;
disp(['׼ȷ��Ϊ��' num2str(accuracy_percentage) '%'])