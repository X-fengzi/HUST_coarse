function out = Encoder(filename)
%%  信源编码
fid = fopen(filename,'r');    %打开文件
data = fread(fid);            %读取文件的二进制存储数据(读取的数据为十进制)
fclose(fid);

bits = de2bi(data);           %将读取的数据转化为二进制
tx_bs = reshape(bits,[],1)';  %并串转化为比特流
out = tx_bs;
end