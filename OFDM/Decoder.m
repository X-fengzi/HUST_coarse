function  Decoder(bitstream,filename)
%% 信源解码
str_bit = reshape(bitstream,[],8);   %串并变换
data = bi2de(str_bit);               %将二进制比特转换为十进制数据

fid = fopen(filename,'w+');          %打开一个的文件
fwrite(fid,data);                    %将数据写入文件
fclose(fid);
end
