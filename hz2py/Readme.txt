Unihan.txt:
从www.unicode.org上下载的unicode编码定义表。

extractor.pl:
从Unihan.txt中搜索跟汉字相关的定义表象，并提取出来生成Mandarin.dat文件。

generator.pl:
遍历Mandarin.dat，生成符合C语言程序要求的“汉字编码——声母”对应数组结构。

占用静态存储器（存储映射表）长度：
25330 * 5 = 126650 bytes = 125KB

需要的动态存储区（存储所有模式串）长度可以忽略。


