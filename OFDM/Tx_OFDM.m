clear
clc
close all
%% ��ʼ��
fs = 10e6;              %����Ƶ��
det_f = 0;
f = 433e6;            %�ز�Ƶ��
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
k = 1;                                            %��ƽֵ
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

%% OFDM ͨ�Ź���
file_name = 'test_10Mb.pdf';
filename_bits = filename_encode(file_name);
bitstream_info = Encoder(file_name);                     %�������ɱ�����
bitstream = [bitstream_info,filename_bits];
frames = Frame(bitstream,frame_length);             %��Դ��������֡����
frame_size = size(frames);
data_Tx = zeros(frame_QAM_length,frame_size(1));
%��ÿ��֡�����ŵ����롢��OFDM������ͬ�������
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
%����ת�����͸�Txѭ������
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




