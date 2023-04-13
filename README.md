# HUST_coarse
这个仓库记录了我在大学期间部分实验课的代码，看心情更新...  
## socket  
>* duplex-talk              基于c语言的socket全双工通信  
>   >client                  客户端  
>   >server                  服务器  
>* duplex-talk-normal       增加了ACK机制，模拟正常通信情况
>   >client                  客户端  
>   >server                  服务器  
>* duplex-talk-overtime     增加了ACK机制，模拟超时超时重传  
>   >client                  客户端  
>   >server                  服务器  
## OFDM(基于Pluto SDR的OFDM调制解调系统)  
#### 环境要求  
> MATLAB R2018b(已经安装Pluto SDR 相关驱动)
> Pluto SDR
#### 代码文件说明  
> OFDM.m &emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;基于Pluto SDR的自发自收系统  
> Tx_OFDM.m &emsp;&emsp;&emsp;&nbsp; 发射端
> Rx_OFDM.m &emsp;&emsp;&emsp;&nbsp; 接收端  
> Encoder.m &emsp;&emsp;&emsp;&emsp;&nbsp; 信源编码：将文件编码为二进制比特流  
> Decoder.m &emsp;&emsp;&emsp;&emsp;&nbsp; 信源解码：给定二进制比特流和文件名，保存为文件  
> filename_encode.m&emsp;文件名字符编码  
> filename_decode.m&emsp;文件名字符解码  
> Frame.m &emsp; &emsp; &emsp;&emsp;&emsp;分帧  
> de_Frame.m &emsp;&emsp;&emsp;&emsp;帧校验，提取帧中的信息比特  
> channel_coding.m &emsp;&nbsp;信道编码：Turbo编码  
> channel_decoding.m &nbsp;信道解码：Turbo解码  
> QAM.m  &emsp; &emsp; &emsp;&emsp;&emsp; &nbsp;QAM映射（4PSK 16QAM）  
> de_QAM.m &emsp;&emsp;&emsp;&emsp;&nbsp;QAM逆映射（4PSK 16QAM）  
> pilot.m &emsp; &emsp; &emsp;&emsp;&emsp;&emsp;加入导频，空载波，组成OFDM信号  
> equalization.m &emsp;&emsp;&emsp;提取导频，去除空载波，进行信道均衡  
> IFFT_cp.m &emsp;&emsp; &emsp;&emsp; IFFT变换，加入循环前缀  
> FFT_cp.m &emsp;&emsp;&emsp;&emsp;&emsp;FFT变换，去除循环前缀  
> create_cazac.m &emsp;&emsp; 生成cazac序列  
> freq_offset_est.m&emsp;&emsp;数据帧频偏估计  
> 其它：&emsp; &emsp; &emsp;&emsp;&emsp;&emsp;用于测试的发送文件
#### 使用说明  
> * ***单个Pluto SDR下的自发自收：*** 连接Pluto SDR，运行OFDM.m,设定好发送文件名，即可仿真实现基于OFDM调制解调的自发自收  
> * ***两个Pluto SDR间文件的传输：*** 两台终端分别连接一个Pluto SDR，一方运行Tx_OFDM.m(设定好发送文件名)，另一方运行Rx_OFDM.m,即可实现文件的传输。（传输距离不宜超过3m，发射天线和接收天线尽量对准） 
#### 程序运行说明
>发送方和接收方的系统参数，如载波频率、基带频率、同步码等  
> 接收方终端若提示“初始化接受失败”，则表明未正确解调出任何数据帧。（建议检查代码参数及通信环境）  
> 接收方终端若提示“数据帧解调出错”，则表明该数据帧出现误码，未能通过校验。
#### 代码逻辑结构
>* OFDM.m &emsp;&emsp;基本上调用了其它所有函数（除Rx_OFDM.m和Tx_OFDM.m）  
>* Tx_OFDM.m  
>   > Encoder.m  
>   > filename_encode.m  
>   > Frame.m  
>   > channel_coding.m  
>   > QAM.m  
>   > pilot.m  
>   > IFFT_cp.m  
>   > create_cazac.m  
>* Rx_OFDM.m  
>   > Decoder.m  
>   > filename_decode.m  
>   > de_Frame.m  
>   > channel_decoding.m  
>   > de_QAM.m  
>   > equalization.m  
>   > FFT_cp.m 
>   > create_cazac.m  
>   > freq_offset_est.m  