function out = equalization(data,N_fft,N_c,N_zero)
%% 空载波位置
zero_position1 = (N_fft-N_zero+3)/2:1:(N_fft+N_zero-1)/2;
zero_position = [1 zero_position1];
%% 导频位置
P_f=1+1*1i;                       %Pilot
P_f_inter = ceil((N_fft-N_zero-1)/(N_fft-N_c)) ;                 %导频间隔
P_f_position1=1:P_f_inter:(N_fft-N_zero+1)/2;
P_f_position1(1) = 2;
P_f_position2=(N_fft+N_zero+1)/2:P_f_inter:N_fft;
P_f_position = [P_f_position1 P_f_position2];
P_f_position = P_f_position(1:N_fft-N_c);
pilot_num = length(P_f_position);
%% 数据位置
data_position = setdiff(1:N_fft,union(P_f_position,zero_position));               %数据位置
%% 
data=data(1:N_fft,:); 
size_data = size(data);
pilot_seq = ones(pilot_num,size_data(2))*P_f;
Rx_pilot=data(P_f_position(1:end),:);                       %接收到的导频
h=Rx_pilot./pilot_seq; 
%分段线性插值：插值点处函数值由连接其最邻近的两侧点的线性函数预测。
%对超出已知点集的插值点用指定插值方法计算函数值
H=interp1( P_f_position(1:end)',h,data_position(1:end)','linear','extrap');
%% 信道校正
data_equ=data(data_position(1:end),:)./H;
data_equ = data_equ./sqrt(mean(abs(data_equ).^2));        %功率归一化
out = reshape(data_equ,[],1);
end
%%