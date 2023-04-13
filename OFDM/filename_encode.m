function out = filename_encode(filename)
%% 给文件名进行编码
len_filename = length(filename);
bits_tail = de2bi(len_filename,8);
file_ascii = [];
 for i = 1:length(filename)
    ascii = unicode2native(filename(i));           % 获取字符串ASCII码
    if length(ascii) == 1
        file_ascii = [file_ascii 0];
        file_ascii = [file_ascii ascii];
    else
        file_ascii = [file_ascii ascii];
    end
 end

bits = dec2bin(file_ascii,8);    % 将二进制ASCII码值转化为二进制编码，得到行为字符个数，列为8的矩阵
bits = bits';               %转置
bits = reshape(bits,[],1)' ;

out = [];
for i = 1:length(bits)
    if bits(i) == '0'
        out = [out,0];
    else
        out = [out,1];
    end
end
out = [out,bits_tail];
end